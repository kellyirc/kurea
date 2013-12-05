Module = require('../../core/Module').Module

class ListModule extends Module
	shortName: "List"
	helpText:
		default: "Lists all the modules this bot has."
	constructor: ->
		super()

		@addRoute "list", (origin, route) =>
			[bot, user, channel] = [origin.bot, origin.user, origin.channel]

			list = (module.shortName for name, module of bot.getModules()).join(", ")
			@reply origin, "Current modules are: #{list}"


exports.ListModule = ListModule