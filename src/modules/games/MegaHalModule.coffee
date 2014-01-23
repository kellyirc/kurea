jsMegaHal = require 'jsmegahal'
color = require 'irc-colors'

module.exports = (Module) ->
	class MegaHalModule extends Module
		shortName: "MegaHal"
		helpText:
			default: "Facilitates learning speech through your speech patterns!"
			'word-count': "Tell you how many words I know!"
			'change-order': "Change the Markov chain order!"
			'order': "Get the current Markov chain order!"

		usage:
			'word-count': 'megahal word-count'
			'change-order': 'megahal change-order <order>'
			'order': 'megahal order'

		constructor: (moduleManager) ->
			super(moduleManager)

			@initMegahal 2

			@addRoute "megahal word-count", (origin, route) =>
				origin.bot.say origin.channel, "I currently know #{Object.keys(@megahal.words).length} words spread across #{Object.keys(@megahal.quads).length} combinations!"

			@addRoute "megahal change-order :order", "markov.modify", (origin, route) =>
				@initMegahal parseInt route.params.order
				origin.bot.say origin.channel, "I've changed my Markov order to #{@megahal.markov}."

			@addRoute "megahal order", (origin, route) =>
				origin.bot.say origin.channel, "My current Markov order is #{@megahal.markov}."

			@on 'message', (bot, sender, channel, message) =>

				@learnFrom message

				@moduleManager.canModuleRoute @, bot.getServer(), channel, false, =>
					if Math.random() > 0.96 or message.toLowerCase().indexOf(bot.getNick().toLowerCase()) isnt -1
						bot.say channel, @generateStatementFrom message

		initMegahal: (order = 4) ->
			@megahal = new jsMegaHal order

			@moduleManager.apiCall 'Log', (logModule) =>
				logModule.forEach (err, msg) =>
					@learnFrom msg.message

		learnFrom: (message) ->

			urlRegex = /(https?:\/\/[^\s]+)/g

			#lets be naive about it for now
			return if message.match urlRegex

			#TODO ignore more bad input?

			@megahal.addMass message

		generateNormalReplyFrom: (message) ->
			@megahal.getReplyFromSentence message

		generateStatementFrom: (message, @minLength = 6) ->
			reply = (@megahal.getReplyFromSentence message).split ' '
			while reply.length < @minLength
				reply = reply.concat @megahal.getReply('').split ' '

			reply.join ' '


	MegaHalModule
