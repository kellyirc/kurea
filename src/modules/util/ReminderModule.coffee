Module = require('../../core/Module').Module
_ = require 'underscore'
_.str = require 'underscore.string'

class Lexer
	constructor: (@tokenMap) ->

	lex: (text) ->
		tokens = []
		currentPosition = 0

		while currentPosition < text.length
			token = null
			for tokenName, tokenDef of @tokenMap
				token = @matchToken text, currentPosition,
					name: tokenName
					def: tokenDef

				if token? then break

			if token?
				# console.log "Got token: #{token.text} (#{token.type})"
				tokens.push token if not @tokenMap[token.type].hidden
				currentPosition = token.end
			else
				throw new Error "Unexpected symbol #{text.charAt(currentPosition)}"

		tokens

	matchToken: (text, currentPosition, tokenDef) ->
		# console.log "Current symbol: #{text.charAt(currentPosition)}"
		# console.log "Now handling", (text.charAt(i) for i in [Math.max(currentPosition-3, 0)..Math.min(currentPosition+3, text.length-1)]), "as", tokenDef.name

		if tokenDef.def.matching instanceof RegExp
			tokenDef.def.matching.lastIndex = currentPosition

			match = tokenDef.def.matching.exec text
			# console.log "Matched! #{match[0]}; #{match.index}" if match?
			if match? and match.index is currentPosition
				# console.log match
				groups = []

				while match[groups.length]?
					groups.push match[groups.length]

				return @makeToken tokenDef, match[0], currentPosition, groups

		else if tokenDef.def.matching instanceof Array
			for item in tokenDef.def.matching
				if item is text.substring currentPosition, currentPosition+item.length
					return @makeToken tokenDef, item, currentPosition

		else if typeof tokenDef.def.matching is 'string'
			if tokenDef.def.matching is text.substring currentPosition, currentPosition+tokenDef.def.matching.length
				return @makeToken tokenDef, tokenDef.def.matching, currentPosition

	makeToken: (tokenDef, text, position, groups) ->
		token =
			type: tokenDef.name
			text: text
			start: position
			end: position + text.length

		if groups? then token.groups = groups

		if tokenDef.def.value?
			token.value = tokenDef.def.value token

		token

class Parser
	constructor: (@lexer, text) ->
		@currentPos = 0
		@tokens = @lexer.lex text

	hasNext: ->
		@currentPos < @tokens.length

	peek: (n = 0) ->
		@tokens[@currentPos+n]

	next: ->
		t = @tokens[@currentPos]
		@currentPos += 1
		t

	check: (token, expected) ->
		return (expected is null) if not token?

		token? and token.type is expected

	assert: (token, expected) ->
		if not @check token, expected
			throw new Error "Expected token type '#{expected}', got '#{token?.type ? 'undefined'}'"
		token

class ReminderParser extends Parser
	parse: ->
		r = {}

		# Parse target
		r.target = @parseTarget()

		# Parse parts
		#   in ...
		#   to ...
		until r.time? and r.task?
			if @isIn() and not r.time?
				r.time = @parseIn()

			else if @isTo() and not r.task?
				r.task = @parseTo()

			else
				throw new Error "Unrecognized text '#{@peek(0).text}'"

		# Make sure we've reached end of input
		@assert @next(), null

		r

	checkText: (token, expected) ->
		@check(token, 'word') and token.text is expected

	assertText: (token, expected) ->
		@assert(token, 'word')

		if not @checkText token, expected
			throw new Error "Expected token text '#{expected}', got '#{token.text}'"

		token

	parseTarget: ->
		(@assert @next(), 'word').text

	isIn: ->
		(@checkText @peek(0), 'in') and (@check @peek(1), 'number') and (@check @peek(2), 'word') and (@peek(2).text in unitList)

	parseIn: ->
		@assertText @next(), 'in'

		totalTime = 0
		while (@check @peek(0), 'number') and (@check @peek(1), 'word') and (@peek(1).text in unitList)
			time = @next()
			unit = @next()

			console.log "Parsed '#{time.text}' '#{unit.text}'"
			totalTime += time.value * unitMap[unit.text]

		totalTime

	isTo: ->
		(@checkText @peek(0), 'to') and (not @check @peek(1), null)

	parseTo: ->
		@assertText @next(), 'to'

		parts = []
		until (@check @peek(0), null) or @isIn()
			parts.push @next().text

		parts.join ' '

unitMap =
	second: 1000
	minute: 60*1000
	hour: 60*60*1000
	day: 24*60*60*1000

aliases =
	second: ['seconds', 's', 'sec']
	minute: ['minutes', 'm', 'min']
	hour: ['hours', 'h']
	day: ['days', 'd']

for key, aliasList of aliases
	unitMap[alias] = unitMap[key] for alias in aliasList

unitList = Object.keys unitMap

tokens =
	space:
		matching: /\s+/g
		hidden: yes

	number:
		matching: /\d+(\.\d+)?/g
		value: (t) -> Number t.text

	word:
		matching: /\w+/g

timeString = (time) ->
	timeParts =
		d: Math.floor(time / (24*60*60*1000))
		h: Math.floor(time / (60*60*1000)) % 24
		m: Math.floor(time / (60*1000)) % 60
		s: Math.floor(time / 1000) % 60
		ms: time % 1000

	units =
		d: ["day", "days"]
		h: ["hour", "hours"]
		m: ["minute", "minutes"]
		s: ["second", "seconds"]
		ms: ["millisecond", "milliseconds"]

	parts = []
	for unit, amnt of timeParts
		if amnt is 0 then continue

		plural = if amnt is 1 then 0 else 1
		parts.push "#{amnt} #{units[unit][plural]}"

	_.str.toSentence parts

class ReminderModule extends Module
	shortName: "Reminder"

	constructor: (moduleManager) ->
		super(moduleManager)

		@reminders = []

		@db = @newDatabase 'reminders'

		# @db.find {}, (err, docs) =>
		# 	@startReminder doc for doc in docs

		@addRoute 'remind :args', (origin, route) =>
			try
				l = new Lexer tokens
				p = new ReminderParser l, route.params.args
				data = p.parse()

				data.own = (data.target is 'me' or data.target is origin.user)
				data.target = origin.user if data.target is 'me'

				data.botName = origin.bot.getName()

				if data.time / (24*60*60*1000) > 24.8
					@reply origin, "Sorry, you can't set a with a duration greater than 24.8 days for now!"
					return

				@reply origin, "Alright, I'll remind #{if data.own then 'you' else data.target} to '#{data.task}' in #{timeString data.time}!"
				console.log data

				# @db.insert data, (err) => console.log "Insertion: ", if err? then "ERROR: #{err}" else "OK"
				@startReminder data

			catch e
				@reply origin, "Oh my, there was a problem! #{e.message}"
				console.error e.stack

	startReminder: (data) ->
		# setTimeout to handle reminder schtuff
		@reminders.push data
		data.timeoutId = setTimeout =>
			console.log "Reminder for #{data.target}: #{data.task}"

			bot = _.find @getBotManager().bots, (bot) => bot.getName() is data.botName

			bot.say data.target, "Hey #{data.target}! #{if data.own then 'You' else data.target} wanted me to remind you to '#{data.task}'!"
		, data.time

exports.ReminderModule = ReminderModule