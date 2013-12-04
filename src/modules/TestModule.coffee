Module = require('../core/Module').Module

class TestModule extends Module
	constructor: ->
		super()

		@addRoute "test", (origin, route) =>
			[bot, channel, user] = [origin.bot, origin.channel, origin.user]

			if not @hasPermission(bot, user, "test.use")
				bot.say(channel, "You do not have the necessary permission! This requires test.use!")
				return

			bot.say(channel, "Hi, my name is #{bot.getName()} but you can call me #{bot.getNick()}!")
			bot.say(channel, "I'm currently in the server #{bot.getServer()} in the channels #{(key for key, value of bot.getChannels()).join(", ")}!")

exports.TestModule = TestModule