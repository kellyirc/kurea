module.exports = (Module) ->
	Q = require 'q'
	request = require 'request'
	colors = require 'irc-colors'

	class BroModule extends Module
		shortName: 'Bro'
		broUrl: 'http://bropages.org'

		constructor: (moduleManager) ->
			super(moduleManager)

			@addRoute "bro :cmd", (origin, route) =>
				@get route.params.cmd, (err, data) =>
					if err?
						console.error err.stack
						@reply origin, "Sorry bro, something happened - #{err.message}"
						return

					for entry in data
						lines = entry.msg.split '\n'
						for line in lines
							c = (if (line.indexOf '#') is 0 then colors.grey else colors.pink)
							@reply origin, c line

						@reply origin, (colors.green "(#{entry.up} upvoted)") + " " + (colors.red "(#{entry.down} downvoted)")

		get: (cmd, callback) ->
			Q.nfcall(request, "#{@broUrl}/#{cmd}.json")

			.then (reply) =>
				[response, body] = reply
				if response.statusCode isnt 200 then throw new Error "Entry #{colors.red cmd} does not exist"

				JSON.parse body

			.nodeify callback

	BroModule