module.exports = (Module) ->
	morse = require 'morse'

	class MorseModule extends Module
		shortName: "Morse"
		helpText:
			default: "Translate to and from Morse code! I'll auto-detect whether to decode or encode!"
		usage:
			default: "morse [message]"

		constructor: ->
			super

			morsePattern = /([\.\-]+(?:\s+[\.\-]+)*)/g

			@addRoute "morse :text", (origin, route) =>
				{text} = route.params

				isMorse = morsePattern.test text

				@reply origin, "#{origin.user}: #{if isMorse then morse.decode text else morse.encode text}"

			# @addRoute "morse from :morseText", (origin, route) =>
			# 	{morseText} = route.params

			# 	console.log "Hurr"

			# 	@reply origin, "#{origin.user}: #{morse.decode morseText}"

			# @on 'message', (bot, sender, channel, message) =>
			# 	morses = (match[1] while (match = morsePattern.exec message)?)

			# 	return if morses.length is 0

			# 	origin =
			# 		user: sender
			# 		bot: bot
			# 		channel: channel
			# 		isPM: not channel?

			# 	@reply origin, "#{origin.user}: #{morses.map((m) -> morse.decode m).join ', '}"