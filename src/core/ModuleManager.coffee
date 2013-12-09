EventEmitter = require('events').EventEmitter
_ = require 'underscore'

BotEvents = require('./Bot').events

class ModuleManager extends EventEmitter
	constructor: (@botManager) ->
		@botListeners = {}
		@modules = require('./ModuleFinder').buildModuleList @

	handleMessage: (bot, from, to, message) =>

		for moduleName, module of @modules

			match = new RegExp("^(#{bot.getNick()}[,:]\s?|\\#{module.commandPrefix}+)(.+)$").exec message
			continue if match is null

			command = match[2].trim() #extra space if you use the nick form. how2regex plz

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
			@botListeners[event] ?= []
			@botListeners[event].push listener

			for bot in @botManager.bots
				bot.conn.on event, listener

		else
			super(event, listener)
	once: (event, listener) ->
		if event in BotEvents
			@botListeners[event] ?= []
			@botListeners[event].push listener
			self = @
			for bot in @botManager.bots
				bot.conn.once event, () ->
					index = self.botListeners[event].indexOf(listener)
					self.botListeners[event].splice index, 1 if index isnt -1
					listener.apply this, arguments
		else
			super(event, listener)

	removeListener: (event, listener) ->
		if event in BotEvents
			if @botListeners[event]?
				index = @botListeners[event].indexOf listener
				@botListeners[event].splice index, 1 if index isnt -1
				for bot in @botManager.bots
					bot.conn.removeListener(event, listener)
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