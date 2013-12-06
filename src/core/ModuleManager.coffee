class ModuleManager
	constructor: ->
		@modules = require('./ModuleFinder').ModuleList

	handleMessage: (bot, from, to, message) =>
		match = /^!(.+)$/.exec(message)
		return if match is null

		command = match[1]

		console.log "Handling '#{command}'"
		for moduleName, module of @modules
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