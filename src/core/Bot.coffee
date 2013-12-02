irc = require 'irc'

class Bot
	constructor: (@botManager) ->
		@conn = new irc.Client 'irc.esper.net', 'Moop',
			channels: [
				'#kellyirc'
			]

		@conn.on 'error', (msg) =>
			console.log 'Error: ', msg

		@conn.on 'raw', (msg) =>
			console.log '>>>', @messageToString(msg)

		@conn.on 'message', (from, to, text, msg) =>
			@botManager.moduleManager.handleMessage(@, from, to, text)

	messageToString: (msg) ->
		return "#{if msg.prefix? then ':' + msg.prefix + ' ' else ''}#{msg.rawCommand} #{msg.args.map((a) -> '"' + a + '"').join(' ')}"

exports.Bot = Bot