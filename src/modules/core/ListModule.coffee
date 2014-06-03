module.exports = (Module) ->
	colors = require 'irc-colors'
	_ = require 'underscore'
	_.str = require 'underscore.string'
	
	class ListModule extends Module
		shortName: "List"
		helpText:
			default: "Lists all the modules this bot has."
		usage:
			default: "list"
		constructor: (moduleManager) ->
			super(moduleManager)
	
			@addRoute "list", (origin) =>
				[bot, channel] = [origin.bot, origin.channel]
				serverName = bot.conn.opt.server

				if !_.contains origin.channel, "#"
					arr = []
					arr.push _.str.strLeft moduleName,"Module" for moduleName of moduleManager.modules

					@reply origin, "While some modules may not work correctly in PM, here is the list:
						#{_.str.toSentence _.sortBy arr, _.identity}"
					return
	
				moduleManager._getModuleActiveData {server: serverName, channel: channel}, (data) =>
					moduleList = []
	
					data.forEach (module) ->
						moduleList.push if module.isEnabled then module.name else colors.red module.name
	
					@reply origin, "Current modules are: #{_.str.toSentence _.sortBy moduleList, _.identity}"
	
				#list = (module.shortName for name, module of bot.getModules()).join(", ")
				#@reply origin, "Current modules are: #{list}"
	
	
	
	ListModule