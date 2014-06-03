module.exports = (Module) ->

	MsTranslator = require "mstranslator"

	class TranslateModule extends Module
		shortName: "Translate"
		helpText:
			default: "Translate some text between languages!"
		usage:
			default: "translate [from-language-code] [to-language-code] [text]"

		constructor: (moduleManager) ->
			super moduleManager

			accessToken = @getApiKey 'azure'

			if not accessToken?
				console.log "No Azure access token was specified, so I won't be able to do translations."
				return

			@translator = new MsTranslator
				client_id: 'Kurea'
				client_secret: accessToken

			@addRoute "translate :from :to :text", (origin, route) =>
				[from, to, text] = [route.params.from, route.params.to, route.params.text]

				@translator.initialize_token () =>
					@translator.translate
						from: from
						to: to
						text: text
					, (err, text) =>
							@reply origin, "Error: #{err}" if err
							@reply origin, "Translation Result: #{text}"