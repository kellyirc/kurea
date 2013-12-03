Module = require('../core/Module').Module

class JoinModule extends Module
	constructor: ->
		super()

		@commands.push "join"

	useCommand: (args) =>
		[bot, user, channel, params] = [args.bot, args.user, args.channel, args.params]

		# TODO: error checking and spliting for multiple joins
		bot.join params, =>
			bot.say channel, "I have joined #{params}."

exports.JoinModule = JoinModule