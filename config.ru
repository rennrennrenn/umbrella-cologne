require 'erb'
require 'net/http'
require 'uri'
require 'json'
require 'byebug'


class WeatherService
  RAIN_CODES = %w(1 3 4 5 6 7 9 10 11 12 13 14 15 16 17 18 35 37 38 39 40 41 42 43 45 46 47)
  WOEID  = 20066504 # cologne 50678
  TEMPERATURE_UNIT = 'c'

  attr_accessor :weather_data

  def initialize
    @weather_data = retrive_weather_data
  end

  def call(_env)
    Rack::Response.new(ERB.new(view).result(binding))
  end

  def view
    <<-HTML
      <!DOCTYPE html>
      <html>
        <head>
          <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/milligram/1.3.0/milligram.css"> 
          <kink rel="stylesheet" href="//fonts.googleapis.com/css?family=Roboto:300,300italic,700,700italic">
          <link rel="stylesheet" href="//cdn.rawgit.com/necolas/normalize.css/master/normalize.css">
          <link rel="stylesheet" href="//cdn.rawgit.com/milligram/milligram/master/dist/milligram.min.css">
          <title>umbrellaCologne</title>
        </head>

        <body>
          <div class="container">
            <h1>Cologne: <%= Time.now.to_date %> </h1>
          </div>

          <div class="container" >
            <button class="button-outline"  >CURRENT: <%= courrent_condition %> </button>
          </div>

          <div class="container" >
            <b> Umbrella: </b><br>
            <i> <%= need_umbrella %> </i>
          </div>

          <div class="container" >
            <h2>Forecast:</h2>
          </div>

        </body>
      </html>
    HTML
  end

  private

def courrent_condition
  "#{@weather_data["condition"]["text"].upcase} (#{@weather_data["condition"]["temp"]} &deg;C)"
end

  def need_umbrella
    if rainy_now? || rainy_later?
      "YES! It will be bad weather today"
    else
      "No! Looks like there will be no rain today"
    end
  end

  def rainy_now?
    RAIN_CODES.include?(@weather_data["condition"]["code"])
  end

  def rainy_later?
    RAIN_CODES.include?(@weather_data["forecast"].first["code"])
  end

  def retrive_weather_data
    query = URI.escape("select * from weather.forecast where woeid = '#{WOEID}' and u = '#{TEMPERATURE_UNIT}' ")
    uri = URI("https://query.yahooapis.com/v1/public/yql?q=#{query}&format=json")
    response = Net::HTTP.get(uri)

    JSON.parse(response)["query"]["results"]["channel"]["item"]
  end
end


#use Rackstatic

run WeatherService.new
#run ->(env){Rack::Response.new(ERB.new(view).result(binding))}
#[200, {}, []]
