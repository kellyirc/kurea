module.exports = (Module) ->
	Q = require 'q'
	request = require 'request'
	querystring = require 'querystring'
	net = require 'net'
	dns = require 'dns'
	_ = str: require 'underscore.string'

	class GeolocateModule extends Module
		shortName: "Geolocate"
		helpText:
			default: "Lock onto the position of the target address or nick, for your nuclear laser cannon needs!"

		constructor: (moduleManager) ->
			super moduleManager

			if not (@getApiKey 'ipinfodb')?
				console.log "No IpInfoDB API key specified in the config"

			@addRoute "geolocate :address", (origin, route) =>
				@reply origin, "Initiating lookup..."

				@requestLookup route.params.address, (err, r) =>
					if err?
						@reply origin, "Uh oh, an error occured! #{err}"
						console.error err.stack
						return

					r[prop] = _.str.titleize r[prop].toLowerCase() for prop in ['cityName', 'regionName', 'countryName']

					console.log r
					@reply origin, "The IP address #{r.ipAddress} points to #{r.latitude}, #{r.longitude} 
									in #{r.cityName}, #{r.regionName}, #{r.countryName} (#{r.countryCode})"

		requestLookup: (address, callback) ->
			Q.fcall =>
				family = net.isIP address
				if family is 0
					Q.ninvoke dns, 'lookup', address

				else [address, family]

			.then (reply) =>
				[address, family] = reply

				query = querystring.stringify
					key: @getApiKey 'ipinfodb'
					ip: address
					format: 'json'

				url = "http://api.ipinfodb.com/v3/ip-city/?#{query}"

				Q.nfcall request, url

			.then (data) =>
				[response, body] = data
				JSON.parse body

			.nodeify callback