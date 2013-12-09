class ModuleManager
	constructor: (@botManager) ->
		@modules = require('./ModuleFinder').buildModuleList(@)

	handleMessage: (bot, from, to, message) =>

		for moduleName, module of @modules

			match = new RegExp("^\\#{module.commandPrefix}(.+)$").exec(message)
			continue if match is null

			command = match[1]

			route = module.router.match(command.split('%').join('%25')) # Router doesn't like %'s
			if route?
				origin =
					bot: bot
					user: from
					channel: if to is bot.getNick() then undefined else to
					isPM: to is bot.getNick()
				try
					route.fn( origin, route )
				catch e
					console.log "Your module is bad and you should feel bad:"
					console.log e.stack
			

exports.ModuleManager = ModuleManager