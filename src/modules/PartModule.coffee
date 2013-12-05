Module = require('../core/Module').Module

class PartModule extends Module
	constructor: ->
		super()

		@addRoute "part *", (origin, route) =>
			[bot, user, channel, chans] = [origin.bot, origin.user, origin.channel, route.splats[0].split(/[\s,]+/)]

			# TODO: allow part messages
			for chan in chans
				bot.part chan, ->
					bot.say channel, "I have left #{chan}."
		@addRoute "part", (origin, route) =>
			[bot, user, channel] = [origin.bot, origin.user, origin.channel]
			bot.part channel

exports.PartModule = PartModule