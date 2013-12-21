module.exports = (Module) ->
	colors = require 'irc-colors'
	
	class ToggleModule extends Module
		shortName: "Toggle"
		helpText:
			default: "Toggle a module on or off in a specific channel."
		usage:
			default: "toggle [module|all-on|all-off]"
	
		constructor: (moduleManager) ->
			super(moduleManager)
	
			@addRoute "toggle all-on", (origin, route) =>
				[bot, user, channel] = [origin.bot, origin.user, origin.channel]
				serverName = bot.conn.opt.server
				moduleManager.enableAllModules serverName, channel
				@reply origin, "All modules have been enabled for #{colors.bold channel}."
	
			@addRoute "toggle all-off", (origin, route) =>
				[bot, user, channel] = [origin.bot, origin.user, origin.channel]
				serverName = bot.conn.opt.server
				moduleManager.disableAllModules serverName, channel
				@reply origin, "All modules have been disabled for #{colors.bold channel}."
	
			@addRoute "toggle :module", (origin, route) =>
				[bot, user, channel, moduleName] = [origin.bot, origin.user, origin.channel, route.params.module]
				serverName = bot.conn.opt.server
	
				#idiot-proofing this
				return if moduleName is 'toggle'
	
				module = moduleManager.findModuleByNameAndAliases moduleName
	
				moduleManager.getModuleActiveData module, serverName, channel, (data) =>
					if data isnt [] and data.length is 1 and data[0].isEnabled
						@reply origin, module.disable serverName, channel
					else
						@reply origin, module.enable serverName, channel
	
	
	ToggleModule