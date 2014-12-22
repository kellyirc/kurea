module.exports = (Module) ->
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

			@getApi().roll = @roll
			@registerApi()
	
			@addRoute "roll :left(\\d+)d:right(\\d+)", (origin, route) =>
				[bot, user, channel, left, right] = [origin.bot, origin.user, origin.channel, route.params.left, route.params.right]
	
				leftVal = parseInt(left)
				rightVal = parseInt(right)
				if leftVal > 1000 or rightVal > 1000
					@reply origin, "#{user}, your input is too high."
				value = @roll leftVal, rightVal
				@reply origin, "#{user}, your #{left}d#{right} rolled #{color.bold(value)}."
	
	
	DiceModule
