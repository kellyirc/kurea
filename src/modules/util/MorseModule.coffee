module.exports = (Module) ->
	morse = require 'morse'

	class MorseModule extends Module
		shortName: "Morse"
		helpText:
			default: "Translate to and from Morse code! I'll also translate any Morse I find in messages!"
		usage:
			default: "morse [from|to] [message]"

		constructor: ->
			super

			morsePattern = /([\.\-]+(?:\s+[\.\-]+)*)/g

			@addRoute "morse to :text", (origin, route) =>
				{text} = route.params

				@reply origin, "#{origin.user}: #{morse.encode text}"

			# @addRoute "morse from :morseText", (origin, route) =>
			# 	{morseText} = route.params

			# 	console.log "Hurr"

			# 	@reply origin, "#{origin.user}: #{morse.decode morseText}"

			@on 'message', (bot, sender, channel, message) =>
				morses = (match[1] while (match = morsePattern.exec message)?)

				return if morses.length is 0

				origin =
					user: sender
					bot: bot
					channel: channel
					isPM: not channel?

				@reply origin, "#{origin.user}: #{morses.map((m) -> morse.decode m).join ', '}"