Module = require('../../core/Module').Module
Client = require 'node-wolfram'
_ = require 'underscore'
_.str = require 'underscore.string'

class WolframModule extends Module
	shortName: "Wolfram"
	helpText:
		default: "Queries WolframAlpha and ouputs results.  To view image results of queries, try !wolfram-img"
		"wolfram-img": "Same as !wolfram, but returns images of all the results instead."
	usage:
		default: "wolfram [query]"
		"wolfram-img": "wolfram-img [query]"

	constructor: (moduleManager) ->
		super(moduleManager)

		apiKey = @getApiKey('wolfram')
		if not apiKey?
			console.error "There's no api key for Wolfram. None of its commands will function."
			return

		@Wolfram = new Client(apiKey)

		@addRoute "wolfram *", (origin, route) =>
			[bot, user, channel, isPM] = [origin.bot, origin.user, origin.channel, origin.isPM]
			query = route.splats[0]
			@Wolfram.query query, (err, response) =>
				try
					if err?
						@reply origin, "Error making query."
						console.error JSON.stringify(err)
						return
					if response.queryresult.$.success is 'false'
						@reply origin, "Wolfram did not understand your query."
						if response.queryresult.tips?
							for tip in response.queryresult.tips[0].tip
								@reply origin, "Tip: #{tip.$.text}"
						if response.queryresult.didyoumeans?
							for didyoumean in response.queryresult.didyoumeans[0].didyoumean
								@reply origin, "Did you mean #{didyoumean._}?"
						return
					[response, primary] = @parseResponse response
					for title, texts of response
						# Post to channel only input and primary pod
						if _.str.startsWith(title, "Input") or title is primary
							if texts instanceof Array
								for text in texts
									@reply origin, "#{title}: #{text}"
							else
								@reply origin, "#{title}: #{texts}"
				catch e
					@reply origin, "Error handling query. (#{e.message})"
					console.error e.stack
	parseResponse: (response) ->
		result = {}
		primary = undefined
		for pod in response.queryresult.pod
			title = pod.$.title
			# result[title] = text for text in subpod.plaintext for subpod in pod.subpod
			result[title] = []
			for subpod in pod.subpod
				hasText = false
				for text in subpod.plaintext
					if not _.str.isBlank(text)
						result[title].push text
						hasText = true
				if not hasText
					for img in subpod.img
						result[title].push img.$.src

			if pod.$.primary
				primary = title

		[result, primary]


				



exports.WolframModule = WolframModule