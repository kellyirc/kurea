Module = require('../core/Module').Module

class JoinModule extends Module
	shortName: "Join"
	helpText:
		default: "Joins a channel. Delimit channels by spaces or commas. USAGE: !join [channel1] {channel2} {channel3}..."
	constructor: ->
		super()

		@addRoute "join *", (origin, route) =>
			[bot, user, channel, chans] = [origin.bot, origin.user, origin.channel, route.splats[0].split(/[\s,]+/)]

			# TODO: error checking and spliting for multiple joins
			for chan in chans
				bot.join chan, =>
					@reply origin, "I have joined #{chan}."

exports.JoinModule = JoinModule