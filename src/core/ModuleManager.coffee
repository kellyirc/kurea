TestModule = require('../modules/TestModule').TestModule # Temporary !!!
JoinModule = require('../modules/JoinModule').JoinModule # Temporary !!!
PartModule = require('../modules/PartModule').PartModule # Temporary !!!

class ModuleManager
	constructor: ->
		@modules = [new TestModule(), new JoinModule(), new PartModule()]

	handleMessage: (bot, from, to, message) =>
		match = /^!(.+)$/.exec(message)
		return if match is null

		command = match[1]

		console.log "Handling '#{command}'"

		for module in @modules
			route = module.router.match(command)
			console.log route
			route.fn( { bot: bot, channel: to, user: from }, route ) if route?

exports.ModuleManager = ModuleManager