class ApiController < ApplicationController
  include RedisInstance
  before_action :"ensure_application/json_request", only: [:update, :create]
  before_action :"ensure_application/x-www-form-urlencoded_request", only: [:drop_off, :locate]
  before_action :check_journey_params, only: [:create]

  def status
    render status: 200
  end

  def update
    service = Fleet::CarsService.new(car_params)
    service.call

    render_out_data_and_status_200
    rescue => exception
    render_400
  end
  
  def create
    service = Rides::JourneyService.new(journey_params)
    service.call
    
    render_out_data_and_status_200
    rescue => exception
    render_400
  end

  def drop_off
    group_id = params["ID"].to_i
    service = Rides::DropOffService.new(group_id)
    service.call

    return render status: 404 if @group_not_found
      
    render_out_data_and_status_200
  end

  def locate
    begin
      group_id = params["ID"].to_i
      find_car_from_group(group_id)
      if @car
        render json: @car
      elsif @group_waiting_in_queue_to_be_processed
        render status: 204
      elsif @car.nil?
        render status: 404
      end
    rescue => exception
      render status: 400
    end
  end

  def error
    render status: 400
  end

  private

  def check_journey_params
    return if journey_params["id"].is_a?(Integer) && journey_params["people"].is_a?(Integer)

    render_400
  end

  def if_group_waiting_find_them_car    
    check_queue
    if @queue_state 
      wait_times =  @wait_list.collect { |x| x[:time] }
      longest_time = wait_times.sort.first 
      
      @wait_list.each do |group|
        
        if group[:time] == longest_time
          @longest_waiting_group_that_fits_in_car = group
        end

        @@queues.each do |queue|
          if queue.first == @longest_waiting_group_that_fits_in_car
            queue.shift
          end
        end
      end
      find_car_for_group(@longest_waiting_group_that_fits_in_car)
    end
  end

  def update_found_car
    @@active_trips.each do |trip| 
      if @longest_waiting_group_that_fits_in_car
        if trip[@longest_waiting_group_that_fits_in_car[:id]]
          @@found_car = trip[@longest_waiting_group_that_fits_in_car[:id]][:car]
        end
      end
    end
  end

  def check_queue    
    @queue_state = false
    @wait_list = []
    @@queues.each do |queue|
      unless @@found_car.nil?
        if queue.first && queue.first[:people] <= @@found_car[:available_seats]
          @queue_state = true
          @wait_list << queue.first
        end
      end
    end
    if @wait_list.empty?
      @running = false
    end
  end

  def find_car_from_group(group_id)
    @group_waiting_in_queue_to_be_processed = false
    @@active_trips.select do |trip|
      if trip[group_id]
        @@found_car = trip[group_id][:car]
        @car = {
          id: @@found_car[:id],
          seats: @@found_car[:seats]
        }
      end
      if trip[group_id].nil?
        if @@journeys[group_id]
          @group_waiting_in_queue_to_be_processed = true
        end
      end
    end
  end

  def render_out_data_and_status_200
    available_cars, journeys, active_trips, queues = ["available_cars", "journeys", "active_trips", "queues"].map do |key|
     redis.get(key)
    end

    render  json: { available_cars: available_cars, journeys: journeys, active_trips: active_trips, queues: queues }, status: 200
  end

  %w[application/json application/x-www-form-urlencoded].each do |content_type|
    define_method("ensure_#{content_type}_request") do
      return if request.headers['Content-Type'] == content_type
    
      render_400
    end
  end

  def render_400
    render status: 400
  end

  def journey_params
    params.permit!["api"]
  end

  def car_params
    params.permit!["_json"]
  end
end
