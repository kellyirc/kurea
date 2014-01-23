jsMegaHal = require 'jsmegahal'
color = require 'irc-colors'

module.exports = (Module) ->
	class MegaHalModule extends Module
		shortName: "MegaHal"
		helpText:
			default: "Facilitates learning speech through your speech patterns!"

		constructor: (moduleManager) ->
			super(moduleManager)

			@megahal = new jsMegaHal 3

			messages = @moduleManager.apiCall 'Log', (logModule) =>
				logModule.forEach (err, msg) =>
					@learnFrom msg.message

			@on 'message', (bot, sender, channel, message) =>

				@learnFrom message

				@moduleManager.canModuleRoute @, bot.getServer(), channel, false, =>
					if Math.random() > 0.96 or message.toLowerCase().indexOf(bot.getNick().toLowerCase()) isnt -1
						bot.say channel, @megahal.getReplyFromSentence message

		learnFrom: (message) ->

			urlRegex = /(https?:\/\/[^\s]+)/g

			#lets be naive about it for now
			return if message.match urlRegex

			#TODO ignore more bad input?

			@megahal.addMass message

	MegaHalModule
