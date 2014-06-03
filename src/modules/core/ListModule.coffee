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

				fullExistingModuleList = []
				fullExistingModuleList.push module.shortName for moduleName,module of moduleManager.modules

				if !_.contains origin.channel, "#"
					return @reply origin, "While some modules may not work correctly in PM, here is the list:
						#{_.str.toSentence _.sortBy fullExistingModuleList, _.identity}"

				moduleManager._getModuleActiveData {server: serverName, channel: channel}, (data) =>
					moduleList = []
	
					data.forEach (module) ->
						moduleList.push if module.isEnabled then module.name else colors.red module.name if _.contains fullExistingModuleList,module.name
	
					@reply origin, "Current modules are: #{_.str.toSentence _.sortBy moduleList, _.identity}"
	
	ListModule