module.exports = (Module) ->
	color = require 'irc-colors'

	class GambleModule extends Module
		shortName: "Gamble"
		helpText:
			default: "Gamble your coins away!"
			"gamble-percent": "Gamble your coins on a percent game!"
		usage:
			default: "gamble-<percent> (check individual commands for more info)"
			"gamble-percent": "gamble-percent [coins] [1-100]p"

		constructor: (moduleManager) ->
			super(moduleManager)

			@addRoute "gamble", (origin) =>
				@reply origin, "Please use a derivative command, check !help gamble for a full listing and then !help that command to get more info."

			#TODO make the % sign work in a route, specifically this one
			@addRoute "gamble-percent :coins :percent([0-9]{1,3}p)", (origin, route) =>
				[user, coins, percent] = [origin.user, parseInt(route.params.coins), parseInt(route.params.percent)]
				if percent > 100 or percent <= 0
					@reply origin, "You can't pick a percentage that doesn't make sense, duh!"
					return

				if coins < 0
					@reply origin, "You can't spend coins you don't have, duh!"
					return

				@moduleManager.apiCall 'Coin', (coinModule) =>

					coinModule.canSpend origin, coins, (canSpend) =>
						if not canSpend
							@reply origin, "You don't have enough coins for that!"
							return

						@moduleManager.apiCall 'Roll', (diceModule) =>

							roll = diceModule.roll 1,100
							if roll <= percent
								win = coins+Math.floor(coins*((percent)/100))
								coinModule.addCoins origin, win, () =>
									@reply origin, "#{user}, you rolled #{color.bold(roll)}, and won #{color.bold(win)} coins."
							else
								coinModule.removeCoins origin, coins, () =>
									@reply origin, "#{user}, you rolled #{color.bold(roll)}, and lost #{color.bold(coins)} coins."

	GambleModule