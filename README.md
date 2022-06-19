
## Design and implementation 

The design of this solution is tailored to meet the challenge's guidelines and requirements. The biggest being not having a database

The first and most important endpoint is the first one: 

**PUT**
**/cars**

In this endpoint (arguably an admin only endpoint) a contact needs to be made in the JSON format containing an enumerable composed of a unique id number and a number of seats representing a car. As soon as this information reaches a process called reset_data_structures is triggered and our controller wide stores of information are reset to their original design:

  - available_cars: An array of 7 hashes that will be used to categorize cars by amount of available seats, 0 being an option meaning no seats available and from 1 thru 6 respectively.
  - active_trips: A simple array for now.
  - queues: Leveraging Ruby's syntax queues will be an array of arrays which behave when compiled to behave as Linked Lists. An array of 6 arrays is created where groups will be categorized by number of people in journey and stored.

Now you may have noticed a pattern in my data strucutre design: cars and queues are categorized by number of available seats and number of people respectively. This is no accident seeing that a "n+1 query problem" could arise from the interaction of an ever growing list of cars against an ever growing list of queues. I seek to cap the amount of calculations when queue meets available cars by having a maximum amount of things to compare against each other: my 6 configurations of available cars by seat against my 6 configurtion of journeys in the queue. 

That way my application does not care how long the journeys queue is or how many available_cars there are in terms of efficiency: A maximum amount calculations is implemented in the design. 

After resetting my data structures to their original state I imendiatly call fot create_cars to take the incoming permitted JSON enumerable coming in to be processed. The enumerable is processed if it´s input type can be handled and is valid we put the car in the as a hash consisting of id, seats ( maximum amount of seats available ) and available_seats ( actual amount of seats available at this time ). If nothing failed in the type checking of the car creation a status 200 OK is rendered and a peek under the hood is presented as all the data structures in the JSON format. 

Our data structures are now reset and our cars are categorized and ready to interact with incoming journeys. 


**POST**
**/journey**


The journey endpoint is designed to accetp a JSON format that's not an enumerable. It's incoming request and input type is checked. A hash is created from the incoming validated information which tallies it's id and amount of people and we feed this hash object into a find_car_for_group(journey) method.

Here we begin by checking the list of available cars starting by the smallest to the biggest car that could take this unseparated group. If a suitable car is found a process is trigered where the car is updated to the new amount of seats according to how many people took this ride and the group is paired in another global structure called active_trips where the id of the group serves as the key to a set of values representing the journey and the car object. 

If a car couldn't be found for the group they are fed into the journey_queue(journey) method which will categorize the group in an array of array by its amount of people in journey as well as it's id and a Time.now timestamp. 

We now have a process that handles an incoming group and either finds it a suitable available car and a fallback method to put them in a queue if no car is found.


**POST**
**/dropoff**

Designed to recieve a group id (in a x-www-form-urlencoded format) This id is fed into a generate_drop_off(group_id) method. 

Here the active_trips enumerable is checked for the incoming id against the available keys, if the key we find the group and the car and delete the pair from the active_trips enumerable. Assuming a drop off we reset the available_seat value in the found car and reinsert it intot the available_cars enumerable.

Assuming we freed up a car we start the if_group_waiting_find_them_car method where we check the queue. Because arrays behave as linked lists in Ruby we can pick the first available positions in our queues knowing that these are overall the poeple waiting the most in all available configurations of amount people that meet the condition of fitting in this car. 

This waitlist is sorted by the time stamp that was generated when they were put in the queue. The group that was waiting the longest is selected and the queue from where the group came is shifted one step forward.

This method is run in a loop updating the amount of seats in the car everytime a group is found for it until the waitlist is empty, meaning: there are no more suitable groups for this car. 

And the car is sent on it's journey.


**POST**
**/locate**

When the dropoff endpoint is contacted with a x-www-form-urlencoded format we check the active_trips enumerable. Using the key fed into the endpoint as the key to the hash we can extract and rebuild the car object to only show the relevant information: id and seats.





# Car Pooling Service Challenge

Design/implement a system to manage car pooling.

At Cabify we provide the service of taking people from point A to point B.
So far we have done it without sharing cars with multiple groups of people.
This is an opportunity to optimize the use of resources by introducing car
pooling.

You have been assigned to build the car availability service that will be used
to track the available seats in cars.

Cars have a different amount of seats available, they can accommodate groups of
up to 4, 5 or 6 people.

People requests cars in groups of 1 to 6. People in the same group want to ride
on the same car. You can take any group at any car that has enough empty seats
for them. If it's not possible to accommodate them, they're willing to wait until 
there's a car available for them. Once a car is available for a group
that is waiting, they should ride. 

Once they get a car assigned, they will journey until the drop off, you cannot
ask them to take another car (i.e. you cannot swap them to another car to
make space for another group).

In terms of fairness of trip order: groups should be served as fast as possible,
but the arrival order should be kept when possible.
If group B arrives later than group A, it can only be served before group A
if no car can serve group A.

For example: a group of 6 is waiting for a car and there are 4 empty seats at
a car for 6; if a group of 2 requests a car you may take them in the car.
This may mean that the group of 6 waits a long time,
possibly until they become frustrated and leave.

## Evaluation rules

This challenge has a partially automated scoring system. This means that before
it is seen by the evaluators, it needs to pass a series of automated checks
and scoring.

### Checks

All checks need to pass in order for the challenge to be reviewed.

- The `acceptance` test step in the `.gitlab-ci.yml` must pass in master before you
submit your solution. We will not accept any solutions that do not pass or omit
this step. This is a public check that can be used to assert that other tests 
will run successfully on your solution. **This step needs to run without 
modification**
- _"further tests"_ will be used to prove that the solution works correctly. 
These are not visible to you as a candidate and will be run once you submit 
the solution

### Scoring

There is a number of scoring systems being run on your solution after it is 
submitted. It is ok if these do not pass, but they add information for the
reviewers.

## API

To simplify the challenge and remove language restrictions, this service must
provide a REST API which will be used to interact with it.

This API must comply with the following contract:

### GET /status

Indicate the service has started up correctly and is ready to accept requests.

Responses:

* **200 OK** When the service is ready to receive requests.

### PUT /cars

Load the list of available cars in the service and remove all previous data
(existing journeys and cars). This method may be called more than once during 
the life cycle of the service.

**Body** _required_ The list of cars to load.

**Content Type** `application/json`

Sample:

```json
[
  {
    "id": 1,
    "seats": 4
  },
  {
    "id": 2,
    "seats": 6
  }
]
```

Responses:

* **200 OK** When the list is registered correctly.
* **400 Bad Request** When there is a failure in the request format, expected
  headers, or the payload can't be unmarshalled.

### POST /journey

A group of people requests to perform a journey.

**Body** _required_ The group of people that wants to perform the journey

**Content Type** `application/json`

Sample:

```json
{
  "id": 1,
  "people": 4
}
```

Responses:

* **200 OK** or **202 Accepted** When the group is registered correctly
* **400 Bad Request** When there is a failure in the request format or the
  payload can't be unmarshalled.

### POST /dropoff

A group of people requests to be dropped off. Whether they traveled or not.

**Body** _required_ A form with the group ID, such that `ID=X`

**Content Type** `application/x-www-form-urlencoded`

Responses:

* **200 OK** or **204 No Content** When the group is unregistered correctly.
* **404 Not Found** When the group is not to be found.
* **400 Bad Request** When there is a failure in the request format or the
  payload can't be unmarshalled.

### POST /locate

Given a group ID such that `ID=X`, return the car the group is traveling
with, or no car if they are still waiting to be served.

**Body** _required_ A url encoded form with the group ID such that `ID=X`

**Content Type** `application/x-www-form-urlencoded`

**Accept** `application/json`

Responses:

* **200 OK** With the car as the payload when the group is assigned to a car. See below for the expected car representation 
```json
  {
    "id": 1,
    "seats": 4
  }
```

* **204 No Content** When the group is waiting to be assigned to a car.
* **404 Not Found** When the group is not to be found.
* **400 Bad Request** When there is a failure in the request format or the
  payload can't be unmarshalled.

## Tooling

At Cabify, we use Gitlab and Gitlab CI for our backend development work. 
In this repo you may find a [.gitlab-ci.yml](./.gitlab-ci.yml) file which
contains some tooling that would simplify the setup and testing of the
deliverable. This testing can be enabled by simply uncommenting the final
acceptance stage. Note that the image build should be reproducible within
the CI environment.

Additionally, you will find a basic Dockerfile which you could use a
baseline, be sure to modify it as much as needed, but keep the exposed port
as is to simplify the testing.

:warning: Avoid dependencies and tools that would require changes to the 
`acceptance` step of [.gitlab-ci.yml](./.gitlab-ci.yml), such as 
`docker-compose`

:warning: The challenge needs to be self-contained so we can evaluate it. 
If the language you are using has limitations that block you from solving this 
challenge without using a database, please document your reasoning in the 
readme and use an embedded one such as sqlite.

You are free to use whatever programming language you deem is best to solve the
problem but please bear in mind we want to see your best!

You can ignore the Gitlab warning "Cabify Challenge has exceeded its pipeline 
minutes quota," it will not affect your test or the ability to run pipelines on
Gitlab.

## Requirements

- The service should be as efficient as possible.
  It should be able to work reasonably well with at least $`10^4`$ / $`10^5`$ cars / waiting groups.
  Explain how you did achieve this requirement.
- You are free to modify the repository as much as necessary to include or remove
  dependencies, subject to tooling limitations above.
- Document your decisions using MRs or in this very README adding sections to it,
  the same way you would be generating documentation for any other deliverable.
  We want to see how you operate in a quasi real work environment.

## Feedback

In Cabify, we really appreciate your interest and your time. We are highly 
interested on improving our Challenge and the way we evaluate our candidates. 
Hence, we would like to beg five more minutes of your time to fill the 
following survey:

- https://forms.gle/EzPeURspTCLG1q9T7

Your participation is really important. Thanks for your contribution!

