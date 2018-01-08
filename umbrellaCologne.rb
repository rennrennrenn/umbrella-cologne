require 'net/http'
require 'uri'
require 'json'
require 'byebug'

query = URI.escape("select * from weather.forecast where woeid = '20066504' and u = 'c' &format=json")

uri = URI("https://query.yahooapis.com/v1/public/yql?q=#{query}")

response = Net::HTTP.get(uri)

weather_forecast = JSON.parse(response)

raincodes = %w(0 1 2 3 4 5 6 7 9 10 11 12 13 14 15 16 17 18 35 37 38 39 40 41 42 43 45 46 47)

if raincodes.any? { |umbrella_condition| weather_forecast["query"]["results"]["channel"]["item"]["forecast"].first["code"] == umbrella_condition}
  if raincodes.any? { |umbrella_condition| weather_forecast["query"]["results"]["channel"]["item"]["condition"]["code"] == umbrella_condition}
    puts "Take your ambrella with you! It will be bad weather the whole day!"
  else
    puts "Take your ambrella with you! It will be bad weather later!"
  end
else
  puts "You dont need an ambrella!"
end
