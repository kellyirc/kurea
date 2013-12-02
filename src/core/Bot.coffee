irc = require 'irc'
path = require 'path'

class Bot
	constructor: (config) ->
		if typeof config is "string"
			config = require path.resolve(config)

		@conn = new irc.Client config.server, config.nick, {}

		@conn.on 'error', (msg) =>
			console.log 'Error: ', msg

		@conn.on 'raw', (msg) =>
			console.log '>>>', @messageToString(msg)

	messageToString: (msg) ->
		return "#{if msg.prefix? then ':' + msg.prefix + ' ' else ''}#{msg.rawCommand} #{msg.args.map((a) -> '"' + a + '"').join(' ')}"


exports.Bot = Bot