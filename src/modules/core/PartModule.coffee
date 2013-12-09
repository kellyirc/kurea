Module = require('../../core/Module').Module

class PartModule extends Module
	shortName: "Part"
	helpText:
		default: "Leaves a channel. Delimit channels by spaces or commas. If no channels given, will leave this channel. USAGE: !part {channel1} {channel2}..."
	constructor: (moduleManager) ->
		super(moduleManager)

		@addRoute "part *", (origin, route) =>
			[bot, user, channel, chans] = [origin.bot, origin.user, origin.channel, route.splats[0].split(/[\s,]+/)]

			# TODO: allow part messages
			for chan in chans
				bot.part chan, ->
					@reply origin, "I have left #{chan}."
		@addRoute "part", (origin, route) =>
			[bot, user, channel] = [origin.bot, origin.user, origin.channel]
			bot.part channel

exports.PartModule = PartModule