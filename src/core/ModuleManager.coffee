EventEmitter = require('events').EventEmitter
_ = require 'underscore'
_.str = require 'underscore.string'

BotEvents = require('./Bot').events

class ModuleManager extends EventEmitter
	constructor: (@botManager) ->
		@botListeners = []
		@modules = require('./ModuleFinder').buildModuleList @

	handleMessage: (bot, from, to, message) =>

		matchRegex = /(?:(.+)[,:]\s+)?(.+)/
		match = matchRegex.exec message
		return if not match?

		[full, targetNick, commandPart] = match
		return if targetNick? and targetNick isnt bot.getNick()
		# console.log "targetNick: #{targetNick}; commandPart: #{commandPart}"

		for moduleName, module of @modules
			if not targetNick?
				# console.log "Has prefix '#{module.commandPrefix}'?", (_.str.startsWith commandPart, module.commandPrefix)
				continue if not _.str.startsWith commandPart, module.commandPrefix

				command = commandPart.substring module.commandPrefix.length

			else command = commandPart

			route = module.router.match command.split('%').join('%25') # Router doesn't like %'s
			if route?
				origin =
					bot: bot
					user: from
					channel: if to is bot.getNick() then undefined else to
					isPM: to is bot.getNick()
				try
					route.fn origin, route
				catch e
					console.error "Your module is bad and you should feel bad:"
					console.error e.stack



	addListener: (event, listener) ->
		@on event, listener
	on: (event, listener) ->
		if event in BotEvents
			for bot in @botManager.bots
				do (bot) =>
					listenerWrapper = (args...) =>
						try
							listener bot, args...
						catch e
							console.error "Error in module bot listener"
							console.error e.stack
					bot.conn.on event, listenerWrapper
					@botListeners.push
						event: event
						listener: listener
						wrapper: listenerWrapper
						bot: bot

		else
			super(event, listener)
	once: (event, listener) ->
		if event in BotEvents
			self = @
			for bot in @botManager.bots
				do (bot) =>
					listenerWrapper = (args...) ->
						try
							for e, index in botListeners when e.listenerWrapper is listenerWrapper
								self.botListeners.splice index, 1
							listener bot, args...
						catch e
							console.error "Error in module bot listener"
							console.error e.stack
					bot.conn.once event, listenerWrapper
					@botListeners.push
						event: event
						listener: listener
						wrapper: listenerWrapper
						bot: bot
		else
			super(event, listener)

	removeListener: (event, listener) ->
		if event in BotEvents
			for index in [@botListeners.length - 1..0]
				e = @botListeners[index]
				if e.event is event and e.listener is listener
					e.bot.conn.removeListener(event, e.wrapper)
					@botListeners.splice index, 1
		else
			super(event, listener)

	removeAllListeners: (event) ->
		super(event)
		for listener in @botListeners[event]
			removeListener(event, listener)

	listeners: (event) ->
		listeners = super(event)
		if @botListeners[event]?
			for listener in @botListeners[event]
				listeners.push listener
		listeners

			

exports.ModuleManager = ModuleManager