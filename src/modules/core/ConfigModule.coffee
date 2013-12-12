Module = require('../../core/Module').Module

class ConfigModule extends Module
	shortName: "Config"
	helpText:
		default: "Various config things. Current commands: set-api-key."
		"set-api-key": "Adds an api key to the config file. Usage: !set-api-key [name] [api key]"
	usage:
		"set-api-key": "set-api-key [name] [api key]"

	constructor: (moduleManager) ->
		super(moduleManager)

		@on 'join', (bot, channel, nick, msg) =>
			if nick is bot.getNick()
				channels = bot.getChannels()
				bot.setConfig 'channels', channels

		@on 'part', (bot, channel, nick, reason, msg) =>
			if nick is bot.getNick()
				channels = bot.getChannels()
				# irc.Client doesn't remove the channel until later
				# so we remove it manually. This is a copy btw
				for i in [channels.length..0]
					if channel is channels[i]
						channels.splice i, 1

				bot.setConfig 'channels', channels

		@on 'kick', (bot, channel, nick, byWho, reason, msg) =>
			if nick is bot.getNick()
				channels = bot.getChannels()
				# irc.Client doesn't remove the channel until later
				# so we remove it manually. This is a copy btw
				for i in [channels.length..0]
					if channel is channels[i]
						channels.splice i, 1
				bot.setConfig 'channels', channels

		@on 'nick', (bot, oldnick, newnick, channels, msg) =>
			# irc.Client already updated it, so check the new nick
			if newnick is bot.getNick()
				bot.setConfig 'nick', newnick

		@addRoute 'set-api-key :name :key', (origin, route) =>
			[name, key] = [route.params.name, route.params.key]
			apiKeys = @moduleManager.botManager.config.apiKeys
			apiKeys[name] = key
			# Yeah we wrote to it directly but whatever.
			@moduleManager.botManager.setConfig('apiKeys', apiKeys)
			@reply origin, "Added the \"#{name}\" key: #{key}"


exports.ConfigModule = ConfigModule