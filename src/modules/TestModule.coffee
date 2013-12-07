Module = require('../core/Module').Module
Q = require('q')
fs = require('fs')

class TestModule extends Module
	shortName: "Test"
	helpText:
		default: "Some test stuff."
		secretilluminaticommand: "no longer a secret"
	constructor: ->
		super()

		@addRoute "test", (origin, route) =>
			[bot, channel, user] = [origin.bot, origin.channel, origin.user]

			# if not @hasPermission(bot, user, "test.use")
			# 	bot.say(channel, "You do not have the necessary permission! This requires test.use!")
			# 	return

			bot.say(channel, "Hi, my name is #{bot.getName()} but you can call me #{bot.getNick()}!")
			bot.say(channel, "I'm currently in the server #{bot.getServer()} in the channels #{bot.getChannels().join(", ")}!")
			bot.say(channel, "My user manager is #{bot.userManager.shortName}!")

			bot.userManager.getUsername origin, (err, username) =>
				if err?
					bot.say(channel, "Welp error: #{err}")
					return

				bot.say(channel, "Your username is #{username}!")

		permtest = (origin, route) =>
			perm = route.params.perm ? "access.test"
			if @hasPermission origin, perm
				@reply origin, "You have permission #{perm}!"
			else
				@reply origin, "BEEP BEEP you lack permission #{perm}"

		@addRoute "permtest", permtest
		@addRoute "permtest :perm", permtest

		@addRoute "info :chan", (origin, route) =>
			[bot, channel, user, chan] = [origin.bot, origin.channel, origin.user, route.params.chan]
			bot.say channel, "These users are in #{chan}: #{bot.getUsersWithPrefix(chan).join(", ")}"
			bot.say channel, "The topic is: #{bot.getTopic(chan)}"

		@addRoute "qtest", (origin, route) =>
			Q.fcall ->
				Q.nfcall fs.readFile, "package.json"

			.then (x) ->
				console.log "Durr", "ALRIGHT #{x}"

			.fail (err) ->
				console.log "Error:", err

exports.TestModule = TestModule