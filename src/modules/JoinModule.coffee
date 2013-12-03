Module = require('../core/Module').Module

class JoinModule extends Module
	constructor: ->
		super()

		@addRoute "join :chan", (origin, route) =>
			[bot, user, channel, chan] = [origin.bot, origin.user, origin.channel, route.params.chan]

			# TODO: error checking and spliting for multiple joins
			bot.join chan, =>
				bot.say channel, "I have joined #{chan}."

exports.JoinModule = JoinModule