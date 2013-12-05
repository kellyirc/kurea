class ModuleManager
	constructor: ->
		@modules = require('./ModuleFinder').ModuleList

	handleMessage: (bot, from, to, message) =>
		match = /^!(.+)$/.exec(message)
		return if match is null

		command = match[1]

		console.log "Handling '#{command}'"
		console.log @modules
		for moduleName, module of @modules
			route = module.router.match(command)
			console.log route
			origin =
				bot: bot
				user: from
				channel: if to is bot.getNick() then undefined else to
				isPM: to is bot.getNick()
			route.fn( origin, route ) if route?

exports.ModuleManager = ModuleManager