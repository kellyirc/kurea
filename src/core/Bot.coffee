irc = require 'irc'
path = require 'path'

wrapperFuncs = [
	'connect'
	'disconnect'
	'send'
	'activateFloodProtection'
	'join'
	'part'
	'say'
	'action'
	'notice'
	'whois'
	'list'
	'ctcp'
]

class Bot
	constructor: (@botManager, config) ->
		if typeof config is "string"
			config = require path.resolve(config)

		@name = config.name
		@nick = config.nick # TODO: keep better track of this, it can change
		@server = config.server

		@conn = new irc.Client config.server, config.nick, config

		@conn.on 'error', (msg) =>
			console.log 'Error: ', msg

		@conn.on 'raw', (msg) =>
			console.log '>>>', @messageToString(msg)

		@conn.on 'message', (from, to, text, msg) =>
			@botManager.moduleManager.handleMessage(@, from, to, text)

	messageToString: (msg) ->
		return "#{if msg.prefix? then ':' + msg.prefix + ' ' else ''}#{msg.rawCommand} #{msg.args.map((a) -> '"' + a + '"').join(' ')}"

# Wraps functions from irc.Client
for f in wrapperFuncs
	Bot::[f] = do (f) ->
		-> irc.Client::[f].apply @conn, arguments

exports.Bot = Bot