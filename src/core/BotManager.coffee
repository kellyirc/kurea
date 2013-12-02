Bot = require('./Bot').Bot

class BotManager
	constructor: () ->
		@bots = []

		# Testin' games
		@bots.push new Bot()

exports.BotManager = BotManager