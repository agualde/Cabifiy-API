require "json"

arr = []

for i in 90001..100000
    hash = {
        "id": i,
        "people": rand(1..6)
    }
    arr << hash.to_json
end



puts arr

