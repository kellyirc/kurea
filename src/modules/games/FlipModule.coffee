Module = require('../../core/Module').Module
color = require 'irc-colors'

class FlipModule extends Module
	shortName: "Flip"
	helpText:
		default: "Flip a coin, normal style! USAGE: !flip"

	constructor: ->
		super()

		@addRoute "flip", (origin, route) =>
			[bot, user, channel] = [origin.bot, origin.user, origin.channel]

			answer = if Math.random() > 0.5 then 'heads' else 'tails'

			@reply origin, "#{user} flipped a coin, and the result was #{color.bold(answer)}."

exports.FlipModule = FlipModule