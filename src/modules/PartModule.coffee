Module = require('../core/Module').Module

class PartModule extends Module
	constructor: ->
		super()

		@addRoute "part :chan", (origin, route) =>
			[bot, user, channel, chan] = [origin.bot, origin.user, origin.channel, route.params.chan]

			# TODO: error checking
			bot.part chan, =>
				bot.say channel, "I have left #{chan}."

exports.PartModule = PartModule