Module = require('../../core/Module').Module
_ = require 'underscore'
_.str = require 'underscore.string'

class Parser
	constructor: (@text) ->
		@skip = /\s+/g
		@currentPos = 0

	setSkip: (skip) ->
		@skip = skip

	doSkip: ->
		@skip.lastIndex = @currentPos
		match = @skip.exec @text

		if match?
			if match.index > @currentPos then return false

			@currentPos = @skip.lastIndex

		false

	hasNextToken: ->
		@currentPos < @text.length

	peekToken: (n = 1) ->
		return null if @currentPos >= @text.length

		@skip.lastIndex = @currentPos
		curPos = @currentPos
		while (match = @skip.exec @text) isnt null
			if --n is 0
				return @text.substring curPos, match.index

			curPos = @skip.lastIndex

		return @text.substring curPos if n is 1
		null

	nextToken: ->
		if not @hasNextToken() then return null

		token = @peekToken()
		@currentPos += token.length
		@doSkip()
		return token

	peekCheckToken: (expected, n = 1) ->
		token = @peekToken(n)
		@tokenEqual(expected, token)

	checkToken: (expected) ->
		token = @nextToken()
		@tokenEqual(expected, token)

	tokenEqual: (token1, token2) ->
		return token1.test(token2) if token1 instanceof RegExp

		return token1 is token2

	assertToken: (expected) ->
		token = @nextToken()
		if not @tokenEqual(expected, token)
			throw new Error("Expected #{expected}, got #{token}")
		token

class ReminderParser extends Parser
	numberRegex: /^\d+(?:\.\d+)?$/
	wordRegex: /^\w+$/

	parse: ->
		r = {}
		# Parse target
		r.target = @parseTarget()

		# Parse parts
		#   in ...
		r.times = @parseIn()

		@assertToken null
		r

	parseTarget: ->
		@assertToken @wordRegex

	parseIn: ->
		@assertToken "in"

		times = []
		until not ( @peekCheckToken(@numberRegex) and @peekCheckToken(@wordRegex, 2) )
			time = @assertToken @numberRegex
			unit = @assertToken @wordRegex

			console.log "Parsed '#{time}' '#{unit}'"
			times.push
				time: _.str.toNumber time, 2
				unit: unit

		return times

class ReminderModule extends Module
	shortName: "Reminder"

	constructor: ->
		super()

		@addRoute 'remind :args', (origin, route) =>
			@reply origin, "Welp! '#{route.params.args}'"

			try
				p = new ReminderParser(route.params.args)
				data = p.parse()

				@reply origin, "SUCCESS; target is '#{data.target}', times are: #{JSON.stringify data.times}"
				console.log data
			catch e
				@reply origin, "Oh my, there was a problem! '#{e.message}'"
				console.log e.stack

exports.ReminderModule = ReminderModule