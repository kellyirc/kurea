class ModuleManager
	constructor: ->
		@modules = require('./ModuleFinder').ModuleList

	handleMessage: (bot, from, to, message) =>
		match = /^!(.+)$/.exec(message)
		return if match is null

		command = match[1]

		console.log "Handling '#{command}'"

		for moduleFile of @modules
			for moduleAssoc of @modules[moduleFile]
				module = @modules[moduleFile][moduleAssoc]
				route = module.router.match(command)
				console.log route
				route.fn( { bot: bot, channel: to, user: from }, route ) if route?

exports.ModuleManager = ModuleManager