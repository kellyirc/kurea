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

		# Private members
		name = config.name
		nick = config.nick # TODO: keep better track of this, it can change
		server = config.server
		channels = []

		# Accessor for private members
		@getName = -> name
		@getNick = -> nick
		@getServer = -> server
		@getChannels = -> channels.slice 0 # Clone the array

		@conn = new irc.Client config.server, config.nick, config

		@conn.on 'error', (msg) =>
			console.log 'Error: ', msg

		@conn.on 'raw', (msg) =>
			console.log '>>>', @messageToString(msg)

		@conn.on 'registered', (msg) =>
			nick = msg.args[0] # The nick we connected with


		@conn.on 'nick', (oldNick, newNick, chans, msg) =>
			nick = newNick if oldNick is nick

		@conn.on 'join', (chan, nick, msg) =>
			channels.push chan if nick is @getNick()

		leaveListener = (leftChannel) =>
			index = channels.indexOf leftChannel
			unless index is -1
				channels.splice index, 1
		@conn.on 'part', leaveListener
		@conn.on 'kick', leaveListener
		@conn.on 'kill', (nick, reason, chan) -> leaveListener chan

		@conn.on 'quit', (nick, reason, channels, message) =>
			if nick is @getNick() # The Bot quit the server
				channels = []

		@conn.on 'message', (from, to, text, msg) =>
			@botManager.moduleManager.handleMessage(@, from, to, text)

	messageToString: (msg) ->
		return "#{if msg.prefix? then ':' + msg.prefix + ' ' else ''}#{msg.rawCommand} #{msg.args.map((a) -> '"' + a + '"').join(' ')}"

# Wraps functions from irc.Client
for f in wrapperFuncs
	Bot::[f] = do (f) ->
		-> irc.Client::[f].apply @conn, arguments

exports.Bot = Bot