Module = require('../../core/Module').Module

class DiceModule extends Module
	shortName: "Roll"
	helpText:
		default: "Roll some dice, D&D style! USAGE: !roll [xdy]"
	roll: (lower, upper, base = 0) ->
		base += Math.floor(Math.random() * upper) + 1 until lower-- is 0
		base

	constructor: ->
		super()

		@addRoute "roll :left(\\d+)d:right(\\d+)", (origin, route) =>
			[bot, user, channel, left, right] = [origin.bot, origin.user, origin.channel, route.params.left, route.params.right]

			value = @roll parseInt(left), parseInt(right)
			bot.say channel, "#{user}, your #{left}d#{right} rolled #{value}."

exports.DiceModule = DiceModule