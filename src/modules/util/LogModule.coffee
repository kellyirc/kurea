Module = require('../../core/Module').Module

class LogModule extends Module
	shortName: "Log"
	helpText:
		default: "I record all of your messages so I can use it in things!"

	constructor: (moduleManager) ->
		super(moduleManager)

		@db = @newDatabase 'messages'

		@on 'message', (bot, sender, channel, message) =>
			@db.insert 
				timestamp: new Date()
				server: bot.getServer()
				channel: channel
				sender: sender
				message: message,
				(err) =>
					console.error err if err?

exports.LogModule = LogModule