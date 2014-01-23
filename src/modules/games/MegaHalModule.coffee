jsMegaHal = require 'jsmegahal'
color = require 'irc-colors'

module.exports = (Module) ->
	class MegaHalModule extends Module
		shortName: "MegaHal"
		helpText:
			default: "Facilitates learning speech through your speech patterns!"
			'word-count': "Tell you how many words I know!"

		usage:
			'word-count': 'word-count'

		constructor: (moduleManager) ->
			super(moduleManager)

			@megahal = new jsMegaHal 2

			messages = @moduleManager.apiCall 'Log', (logModule) =>
				logModule.forEach (err, msg) =>
					@learnFrom msg.message

			@addRoute "megahal word-count", (origin, route) =>
				origin.bot.say origin.channel, "I currently know #{Object.keys(@megahal.words).length} words spread across #{Object.keys(@megahal.quads).length} combinations!"

			@on 'message', (bot, sender, channel, message) =>

				@learnFrom message

				@moduleManager.canModuleRoute @, bot.getServer(), channel, false, =>
					if Math.random() > 0.96 or message.toLowerCase().indexOf(bot.getNick().toLowerCase()) isnt -1
						bot.say channel, @generateStatementFrom message

		learnFrom: (message) ->

			urlRegex = /(https?:\/\/[^\s]+)/g

			#lets be naive about it for now
			return if message.match urlRegex

			#TODO ignore more bad input?

			@megahal.addMass message

		generateStatementFrom: (message, @minLength = 6) ->
			reply = (@megahal.getReplyFromSentence message).split ' '
			while reply.length < @minLength
				reply = reply.concat @megahal.getReply('').split ' '

			reply.join ' '


	MegaHalModule
