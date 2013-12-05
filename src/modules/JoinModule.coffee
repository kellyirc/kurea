Module = require('../core/Module').Module

class JoinModule extends Module
	constructor: ->
		super()

		@addRoute "join *", (origin, route) =>
			[bot, user, channel, chans] = [origin.bot, origin.user, origin.channel, route.splats[0].split(/[\s,]+/)]

			# TODO: error checking and spliting for multiple joins
			for chan in chans
				bot.join chan, ->
					bot.say channel, "I have joined #{chan}."

exports.JoinModule = JoinModule