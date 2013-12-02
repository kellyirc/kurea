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
	constructor: (config) ->
		if typeof config is "string"
			config = require path.resolve(config)

		@conn = new irc.Client config.server, config.nick, config

		@conn.on 'error', (msg) =>
			console.log 'Error: ', msg

		@conn.on 'raw', (msg) =>
			console.log '>>>', @messageToString(msg)

		@conn.on 'message', (from, to, text, msg) =>
			# let module manager handle text messages

	messageToString: (msg) ->
		return "#{if msg.prefix? then ':' + msg.prefix + ' ' else ''}#{msg.rawCommand} #{msg.args.map((a) -> '"' + a + '"').join(' ')}"

# Wraps functions from irc.Client
for f in wrapperFuncs
	Bot::[f] = do (f) ->
		-> irc.Client::[f].apply @conn, arguments


exports.Bot = Bot