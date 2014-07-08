module.exports = (Module) ->

	weather = require "openweathermap"
	color = require "irc-colors"

	class WeatherModule extends Module
		shortName: "Weather"
		helpText:
			default: "Get the weather for a place!"
		usage:
			default: "weather [city]"

		constructor: (moduleManager) ->
			super moduleManager

			tF = (str, mode) -> "#{str}°#{mode}"

			weatherFunction = (origin, route, mode = "metric") =>
				city = route.params.city

				dS = if mode is "metric" then "C" else "F"
				try
					weather.now
						q: city
						units: mode
					, (json) =>

						conditionString = if json.weather.size is 0 then 'None' else (json.weather.map (w)-> return w.description).join ', '

						@reply origin, "Weather in #{color.bold (if json.name then json.name else city)} (#{json.coord.lat}, #{json.coord.lon}) -
							#{color.bold 'Low Temp'}: #{tF json.main.temp_min, dS},
							#{color.bold 'Temp'}: #{tF json.main.temp, dS},
							#{color.bold 'High Temp'}: #{tF json.main.temp_max, dS},
							#{color.bold 'Humidity'}: #{json.main.humidity}%,
							#{color.bold 'Wind Speed'}: #{json.wind.speed}mph,
							#{color.bold 'Conditions'}: #{conditionString}"
				catch e
					@reply origin, "Could not get the weather at this point in time. Try again?"

			@addRoute "weather :city", weatherFunction
			@addRoute "weather-i :city", (origin, route) => weatherFunction origin, route, "imperial"

	WeatherModule
