module.exports = (Module) ->
	google = require 'google'

	class GoogleModule extends Module
		shortName: "Google"
		helpText:
			default: "Gets search results from a Google query."
		usage:
			default: "google [query]"

		constructor: (moduleManager)->
			super moduleManager
			counter = 0
			links = undefined
			@addRoute "google *", (origin, route) =>
				query = route.splats[0]
				counter = 0
				try
					google query, (err, n, l) =>
						if err
							console.error err
							@reply origin, "Unable to get results. Google is probably throttling requests."
							return
						if l.length is 0
							@reply origin, "No results found."
							return
						links = l
						if counter < links.length
							@reply origin, "#{links[counter].title} - #{links[counter].link}"
							counter++
				catch e
					@reply origin, "Unable to make query."
			@addRoute "next", (origin, route) =>
				if not links?
					@reply origin, "You have not made a query yet."
				if counter < links.length
					@reply origin, "#{links[counter].title} - #{links[counter].link}"
					counter++
				else
					console.log "No more results."