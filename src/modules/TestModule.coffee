Module = require('../core/Module').Module

class TestModule extends Module
	constructor: ->
		super()

		@addRoute "test", (origin, route) =>
			[bot, channel, user] = [origin.bot, origin.channel, origin.user]

			# if not @hasPermission(bot, user, "test.use")
			# 	bot.say(channel, "You do not have the necessary permission! This requires test.use!")
			# 	return

			bot.say(channel, "Hi, my name is #{bot.getName()} but you can call me #{bot.getNick()}!")
			bot.say(channel, "I'm currently in the server #{bot.getServer()} in the channels #{bot.getChannels().join(", ")}!")

		@addRoute "info :chan", (origin, route) =>
			[bot, channel, user, chan] = [origin.bot, origin.channel, origin.user, route.params.chan]
			bot.say channel, "These users are in #{chan}: #{bot.getUsersWithPrefix(chan).join(", ")}"
			bot.say channel, "The topic is: #{bot.getTopic(chan)}"
exports.TestModule = TestModule