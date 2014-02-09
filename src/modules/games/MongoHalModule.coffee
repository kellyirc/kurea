color = require 'irc-colors'
MongoClient = require('mongodb').MongoClient
Q = require 'q'
fs = require 'fs'

if fs.existsSync 'config.json'
	config = require '../../../config.json'
	databaseURL = config.storageURL

# WARNING
# this requires jsmongohal to be set up beforehand
# see https://github.com/seiyria/jsmongohal for details

module.exports = (Module) ->
	class MongoHalModule extends Module
		shortName: "MongoHal"
		helpText:
			default: "Facilitates learning speech through your speech patterns (with a different backend from MegaHal)!"
			'change-order': "Change the Markov chain order!"
			'order': "Get the current Markov chain order!"

		usage:
			'change-order': 'mongohal change-order <order>'
			'order': 'mongohal order'

		constructor: (moduleManager) ->
			super(moduleManager)

			_isReady = Q.defer()
			@databaseReady = _isReady.promise

			MongoClient.connect "mongodb://#{databaseURL}/jsmegahal", {server:{auto_reconnect:true}}, (e, @db) =>
				_isReady.fail e if e?
				throw e if e?

				_isReady.resolve @db

			@order = 2

			@addRoute "mongohal change-order :order", "markov.modify", (origin, route) =>
				@order = parseInt route.params.order
				origin.bot.say origin.channel, "I've changed my Markov order to #{@order}."

			@addRoute "mongohal order", (origin, route) =>
				origin.bot.say origin.channel, "My current Markov order is #{@order}."

			@on 'message', (bot, sender, channel, message) =>

				@learnFrom message

				@moduleManager.canModuleRoute @, bot.getServer(), channel, false, =>
					if Math.random() > 0.96 or message.toLowerCase().indexOf(bot.getNick().toLowerCase()) isnt -1
						@generateNormalReplyFrom message, (message) -> bot.say channel, message

		learnFrom: (message) ->

			urlRegex = /(https?:\/\/[^\s]+)/g

			#lets be naive about it for now
			return if message.match urlRegex

			Q.when @databaseReady, (db) =>
				message.split(/[!?\.]/).forEach (e) =>
					db.eval('function(sentence, markov) { add(sentence, null, markov); }', [e, @order], () ->)

		randomInt: (min,max) ->
			return Math.floor Math.random() * (max - min + 1) + min

		generateNormalReplyFrom: (message, callback) ->

			words = message.split ' '
			word = words[@randomInt 0, words.length]

			Q.when @databaseReady, (db) =>
				db.eval('function(word, markov) { return reply(word, markov); }', [word, @order], (e, reply) -> callback reply)


	MongoHalModule
