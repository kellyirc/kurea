module.exports = (Module) ->
	Q = require 'q'
	request = require 'request'
	colors = require 'irc-colors'

	class BroModule extends Module
		shortName: 'Bro'

		helpText:
			default: "Look up common use-cases at the bropages @ http://bropages.org/"

		usage:
			default: "bro [command]"

		broUrl: 'http://bropages.org'

		constructor: (moduleManager) ->
			super(moduleManager)

			@addRoute "bro :cmd", (origin, route) =>
				@get route.params.cmd, (err, data) =>
					if err?
						console.error err.stack
						@reply origin, "Sorry bro, something happened - #{err.message}"
						return

					e.lines = e.msg.split '\n' for e in data

					displayEntry = (entry) =>
						for line in entry.lines
							c = (if (line.indexOf '#') is 0 then colors.grey else colors.pink)
							@reply origin, c line

						@reply origin, (colors.green "(#{entry.up} upvoted)") + " " + (colors.red "(#{entry.down} downvoted)")

					if origin.isPM
						displayEntry entry for entry in data

					else
						smallEntries = (entry for entry in data when entry.lines.length <= 3)

						if smallEntries.length > 0
							displayEntry smallEntries[0] # display first entry
							@reply origin, "Use in PM to get all entries."
						else
							@reply origin, "No short enough entries found; use in PM to get all entries."

		get: (cmd, callback) ->
			Q.nfcall(request, "#{@broUrl}/#{cmd}.json")

			.then (reply) =>
				[response, body] = reply
				if response.statusCode isnt 200 then throw new Error "Entry #{colors.red cmd} does not exist"

				JSON.parse body

			.nodeify callback

	BroModule