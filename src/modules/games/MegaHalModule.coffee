jsMegaHal = require 'jsmegahal'
color = require 'irc-colors'

module.exports = (Module) ->
	class MegaHalModule extends Module
		shortName: "MegaHal"
		helpText:
			default: "Facilitates learning speech through your speech patterns!"

		constructor: (moduleManager) ->
			super(moduleManager)

			@megahal = new jsMegaHal()

			messages = @moduleManager.apiCall 'Log', (logModule) =>

				logModule.forEach (err, msg) =>
					@learnFrom msg.message

			@on 'message', (bot, sender, channel, message) =>

				@learnFrom message

				@moduleManager.canModuleRoute @, bot.getServer(), channel, false, =>
					if Math.random() > 0.96 or message.indexOf(bot.getNick()) isnt -1
						try
							bot.say channel, @megahal.getReplyFromSentence message
						catch err
						#there were no adequate phrases in the database
						#I don't know why this throws an error, and I don't know why there's
						#no way to check for this in node-markov

		learnFrom: (message) ->

			urlRegex = /(https?:\/\/[^\s]+)/g

			#lets be naive about it for now
			return if message.match urlRegex

			#TODO ignore more bad input?

			@megahal.add message

	MegaHalModule
