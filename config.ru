require 'erb'
require 'net/http'
require 'uri'
require 'json'
require 'byebug'


class WeatherService
  def call(_env)
    Rack::Response.new(ERB.new(view).result(binding))
  end


  def view 
    <<-HTML
      <!DOCTYPE html>
      <html>
        <head>
           <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/pure/1.0.0/base-min.css"> 
          <title>umbrellaCologne</title>
        </head>
        <body>
          <div>
            <h1>Cologne:</h1>
          </div>
          <div>
            <%= need_umbrella %>
          </div>
        </body>
      </html>
    HTML
  end

  private

  def need_umbrella
    query = URI.escape("select * from weather.forecast where woeid = '20066504' and u = 'c' &format=json")

    uri = URI("https://query.yahooapis.com/v1/public/yql?q=#{query}")

    response = Net::HTTP.get(uri)

    weather_forecast = JSON.parse(response)

    raincodes = %w(0 1 2 3 4 5 6 7 9 10 11 12 13 14 15 16 17 18 35 37 38 39 40 41 42 43 45 46 47)

    if raincodes.any? { |umbrella_condition| weather_forecast["query"]["results"]["channel"]["item"]["forecast"].first["code"] == umbrella_condition}
      if raincodes.any? { |umbrella_condition| weather_forecast["query"]["results"]["channel"]["item"]["condition"]["code"] == umbrella_condition}
        "YES! Take your ambrella with you! It will be bad weather the whole day!"
      else
        "YES! Take your ambrella with you! It will be bad weather later!"
      end
    else
      "You don't need an ambrella!"
    end
  end
end


use Rackstatic

run WeatherService.new
#run ->(env){Rack::Response.new(ERB.new(view).result(binding))}
#[200, {}, []]
