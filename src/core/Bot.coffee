irc = require 'irc'

class Bot
	constructor: () ->
		@conn = new irc.Client 'irc.esper.net', 'Moop',
			channels: [
				'#warcan'
			]

		@conn.on 'error', (msg) =>
			console.log 'Error: ', msg

		@conn.on 'raw', (msg) =>
			console.log '>>>', @messageToString(msg)

	messageToString: (msg) ->
		return "#{if msg.prefix? then ':' + msg.prefix + ' ' else ''}#{msg.rawCommand} #{msg.args.map((a) -> '"' + a + '"').join(' ')}"

exports.Bot = Bot