module.exports = (Module) ->

	class LogModule extends Module
		shortName: "Log"
		helpText:
			default: "I record all of your messages so I can use it in things!"

		constructor: (moduleManager) ->
			super(moduleManager)

			@db = @newDatabase 'messages'

			@getApi().forEach = (callback) =>
				@db.findForEach {}, callback

			@getApi().mapReduce = (map, reduce, query, callback) =>
				@db.mapReduce map, reduce, query, callback

			@registerApi()

			@on 'message', (bot, sender, channel, message) =>
				@db.insert
					timestamp: new Date()
					server: bot.getServer()
					channel: channel
					sender: sender
					message: message,
					(err) =>
						console.error err if err?

	LogModule