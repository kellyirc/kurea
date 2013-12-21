markov = require 'markov'
color = require 'irc-colors'

module.exports = (Module) ->
	class MarkovModule extends Module
		shortName: "Markov"
		helpText:
			default: "Facilitates learning speech through your speech patterns!"

		constructor: (moduleManager) ->
			super(moduleManager)

			urlRegex = /(https?:\/\/[^\s]+)/g
			commandRegex = /^(?:([^\s]+)[,:]\s+)?(.+)$/

			@markov = markov()

			messages = @moduleManager.apiCall 'Log', (logModule) =>

				logModule.forEach (err, msg) =>
					@markov.seed msg.message

			@on 'message', (bot, sender, channel, message) =>

				@markov.seed message

				@moduleManager.canModuleRoute @, bot.getServer(), channel, false, =>
					if Math.random() > 0.96 or message.indexOf(bot.getNick()) isnt -1
						try
							bot.say channel, (@markov.respond message).join ' '
						catch err
						#there were no adequate phrases in the database
						#I don't know why this throws an error, and I don't know why there's
						#no way to check for this in node-markov



	MarkovModule
