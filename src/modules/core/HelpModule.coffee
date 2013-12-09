Module = require('../../core/Module').Module

class HelpModule extends Module
	shortName: "Help"
	helpText:
		default: "Provides helpful information on any module. USAGE: !help [module name | module alias]"
	constructor: (moduleManager) ->
		super(moduleManager)

		@addRoute "help :name", (origin, route) =>
			[bot, user, channel, name] = [origin.bot, origin.user, origin.channel, route.params.name.toLowerCase()]

			for moduleName, module of bot.getModules()
				for alias of module.helpText when alias isnt "default"
					if name is alias.toLowerCase()
						@reply origin, module.helpText[alias]
						return
				if name is module.shortName.toLowerCase()
					@reply origin, module.helpText["default"]


exports.HelpModule = HelpModule