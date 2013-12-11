Module = require('../../core/Module').Module

class HelpModule extends Module
	shortName: "Help"

	helpText:
		default: "Provides helpful information on any module."
	usage:
		default: "help [module name | module alias]"

	getUsageText: (module, alias) ->
		"«Usage: #{module.commandPrefix}#{module.usage[alias]}»" if 'usage' of module and alias of module.usage

	getHelpText: (module, alias) ->
		usageText = @getUsageText module,alias
		usageText ?= ''
		"#{module.helpText[alias]} #{usageText}"

	constructor: (moduleManager) ->
		super(moduleManager)

		@addRoute "help :name", (origin, route) =>
			[bot, user, channel, name] = [origin.bot, origin.user, origin.channel, route.params.name.toLowerCase()]

			for moduleName, module of bot.getModules()
				for alias of module.helpText when alias isnt "default"
					if name is alias.toLowerCase()
						@reply origin, @getHelpText module, alias
						return
				if name is module.shortName.toLowerCase()
					@reply origin, @getHelpText module, 'default'


exports.HelpModule = HelpModule