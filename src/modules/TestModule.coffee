Module = require('../core/Module').Module

class TestModule extends Module
	constructor: ->
		super()

		@commands.push "test"

	useCommand: (args) =>
		[bot, user, channel] = [args.bot, args.user, args.channel]

		if not @hasPermission(bot, user, "test.use")
			bot.say(channel, "You do not have the necessary permission! This requires test.use!")
			return

		bot.say(channel, "Testing!")

exports.TestModule = TestModule