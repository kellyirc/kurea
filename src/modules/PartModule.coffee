Module = require('../core/Module').Module

class PartModule extends Module
	constructor: ->
		super()

		@commands.push "part"

	useCommand: (args) =>
		[bot, user, channel, params] = [args.bot, args.user, args.channel, args.params]

		# TODO: error checking
		bot.part params, =>
			bot.say channel, "I have left #{params}."

exports.PartModule = PartModule