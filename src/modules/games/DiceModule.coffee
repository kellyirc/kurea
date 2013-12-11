Module = require('../../core/Module').Module
color = require 'irc-colors'

class DiceModule extends Module
	shortName: "Roll"
	helpText:
		default: "Roll some dice, D&D style!"
	usage:
		default: "roll [#dice]d[#sides]"
	roll: (lower, upper, base = 0) ->
		base += Math.floor(Math.random() * upper) + 1 until lower-- is 0
		base

	constructor: (moduleManager) ->
		super(moduleManager)

		@addRoute "roll :left(\\d+)d:right(\\d+)", (origin, route) =>
			[bot, user, channel, left, right] = [origin.bot, origin.user, origin.channel, route.params.left, route.params.right]

			value = @roll parseInt(left), parseInt(right)
			@reply origin, "#{user}, your #{left}d#{right} rolled #{color.bold(value)}."

exports.DiceModule = DiceModule