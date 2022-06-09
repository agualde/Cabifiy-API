class ApplicationController < ActionController::API

    @cars = Car.all 
    
    test_1 = {}
    test_2 = {}
    test_3 = {}
    test_4 = {}
    test_5 = {}
    test_6 = {}

    @avalaible_cars = []

    @cars.each do |car|        
        if car.seats == 1
            test_1[car.id] = car
        elsif car.seats == 2
            test_2[car.id] = car
        elsif car.seats == 3
            test_3[car.id] = car
        elsif car.seats == 4
            test_4[car.id] = car
        elsif car.seats == 5
            test_5[car.id] = car
        elsif car.seats == 6
            test_6[car.id] = car
        end
    end
    @avalaible_cars.push(test_1, test_2, test_3, test_4, test_5, test_6)
end
    