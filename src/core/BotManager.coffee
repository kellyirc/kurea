Bot = require('./Bot').Bot
ModuleManager = require('./ModuleManager').ModuleManager

class BotManager
	constructor: () ->
		@bots = []
		@moduleManager = new ModuleManager()

		# Testin' games
		@bots.push new Bot(@, "./config.json")

exports.BotManager = BotManager