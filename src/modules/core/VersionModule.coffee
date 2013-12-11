Module = require('../../core/Module').Module
jsonver = require('../../../package.json').version

class VersionModule extends Module
	shortName: "Version"
	helpText:
		default: "Tells you what version this bot is using right now."
	usage:
		default: "version"
	constructor: (moduleManager) ->
		super(moduleManager)

		@addRoute "version", (origin, route) =>
			[bot, user, channel] = [origin.bot, origin.user, origin.channel]

			@reply origin, "The current version is #{jsonver}"

exports.VersionModule = VersionModule