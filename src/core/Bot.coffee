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

		# Accessor for private members
		@getName = -> name


		@conn = new irc.Client config.server, config.nick, config

		@conn.on 'error', (msg) =>
			console.log 'Error: ', msg

		@conn.on 'raw', (msg) =>
			console.log '>>>', @messageToString(msg)

		@conn.on 'message', (from, to, text, msg) =>
			@botManager.moduleManager.handleMessage(@, from, to, text)

	messageToString: (msg) ->
		return "#{if msg.prefix? then ':' + msg.prefix + ' ' else ''}#{msg.rawCommand} #{msg.args.map((a) -> '"' + a + '"')}"

	# Returns the channels the bot is currently in.
	getChannels: -> chan for chan of @conn.chans # Clone the object

	getUsers: (chan) ->
		chan = chan.toLowerCase()
		users = {}
		users = @conn.chans[chan].users if @conn.chans[chan]?
		key for key,value of @conn.chans[chan].users

	getUsersWithPrefix: (chan) ->
		chan = chan.toLowerCase()
		users = {}
		users = @conn.chans[chan].users if @conn.chans[chan]?
		value+key for key,value of @conn.chans[chan].users

	getTopic: (chan) ->
		return @conn.chans[chan].topic if @conn.chans[chan]?
		return ''

	getNick: -> @conn.nick

	getServer: -> @conn.opt.server

	getModules: -> @botManager.moduleManager.modules

# Wraps functions from irc.Client
for f in wrapperFuncs
	Bot::[f] = do (f) ->
		-> irc.Client::[f].apply @conn, arguments

exports.Bot = Bot