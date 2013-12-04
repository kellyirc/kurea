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
		return "#{if msg.prefix? then ':' + msg.prefix + ' ' else ''}#{msg.rawCommand} #{msg.args.map((a) -> '"' + a + '"').join(' ')}"

	### 
	Returns an object like this
	{ 
		'#someloserschannel': {
			key: '#someloserschannel',
 			serverName: '#someloserschannel',
 			users: { Moop: '@', Jar: '' },
 			mode: '+nt',
 			created: '1386192406' },
 		'#kellyirc': ...
	}
	###
	getChannels: -> JSON.parse(JSON.stringify(@conn.chans)) # Clone the object

	getNick: -> @conn.nick

	getServer: -> @conn.opt.server

# Wraps functions from irc.Client
for f in wrapperFuncs
	Bot::[f] = do (f) ->
		-> irc.Client::[f].apply @conn, arguments

exports.Bot = Bot