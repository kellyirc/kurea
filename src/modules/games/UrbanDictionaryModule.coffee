module.exports = (Module) ->

	request = require "request"
	color = require "irc-colors"

	class UrbanDictionaryModule extends Module
		shortName: "Urban"
		helpText:
			default: "Check out UrbanDictionary!"
		usage:
			default: "ud [term]"

		constructor: (moduleManager) ->
			super moduleManager

			@addRoute "ud :term", (origin, route) =>
				term = route.params.term

				request
					url: "http://api.urbandictionary.com/v0/define"
					qs:
						page: 1
						term: term
					json: true
				, (e, r, body) =>
						if e or body.result_type isnt 'exact'
							@reply origin, "Term #{term} not found"
							return

						json = body.list[0]
						@reply origin, "#{color.bold json.word} (#{json.permalink}) - #{json.definition.split('\r\n').join(' ')}"
						@reply origin, "#{color.bold 'Example Usage'} #{json.example.split('\r\n').join(' ')}"


	UrbanDictionaryModule