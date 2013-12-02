Bot = require('./Bot').Bot
ModuleManager = require('./ModuleManager').ModuleManager
PermissionManager = require('./PermissionManager').PermissionManager

class BotManager
	constructor: () ->
		@bots = []
		@moduleManager = new ModuleManager()
		@permissionManager = new PermissionManager()

		# Testin' games
		@bots.push new Bot(@, "./config.json")

exports.BotManager = BotManager