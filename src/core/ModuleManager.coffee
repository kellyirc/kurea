EventEmitter = require('events').EventEmitter
_ = require 'underscore'
_.str = require 'underscore.string'
Database = require 'nedb'
color = require 'irc-colors'
Q = require 'q'

BotEvents = require('./Bot').events

class ModuleManager extends EventEmitter

	moduleActiveSettings: new Database { autoload: true, filename: 'data/bot-core/module-settings.kdb' }
	apiMap: {}

	constructor: (@botManager) ->
		@botListeners = []
		@modules = require('./ModuleFinder').buildModuleList @

	findModuleByNameAndAliases: (name) =>

		name = name.toLowerCase()

		possibleModule = null

		for moduleName,module of @modules

			break if possibleModule isnt null

			compareNames = [module.shortName.toLowerCase()]

			for alias of module.usage when alias isnt 'default'
				compareNames.push alias.toLowerCase()

			possibleModule = module if -1 isnt compareNames.indexOf name

		possibleModule

	canModuleRoute: (module, server, channel, isPM, callback) =>

		if isPM or module.shortName is 'Toggle'
			callback()
			return

		@moduleActiveSettings.find { name: module.shortName, server: server, channel: channel }, (err, data) ->
			callback() if (data isnt [] and data.length is 1 and data[0].isEnabled)

	_getModuleActiveData: (search, callback) ->
		@moduleActiveSettings.find search, (err, docs) ->
			callback docs

	getModuleActiveData: (module, server, channel, callback) =>
		return if module is null

		@_getModuleActiveData { name: module.shortName, server: server, channel: channel }, callback

	enableAllModules: (server, channel) =>
		for moduleName,module of @modules
			@enableModule module,server,channel

	disableAllModules: (server, channel) =>
		for moduleName,module of @modules
			@disableModule module,server,channel

	enableModule: (module, server, channel) =>

		@moduleActiveSettings.update { name: module.shortName, server: server, channel: channel },
									{ $set: { isEnabled: true } },
									{ upsert: true }

		"Module #{color.bold module.shortName} is now #{color.bold 'enabled'} in #{channel}."

	disableModule: (module, server, channel) =>

		@moduleActiveSettings.update { name: module.shortName, server: server, channel: channel },
									{ $set: { isEnabled: false } },
									{ upsert: true }

		"Module #{color.bold module.shortName} is now #{color.bold 'disabled'} in #{channel}."

	handleMessage: (bot, from, to, message) =>

		commandPart = message
		nickUsage = false
		if (_.str.startsWith commandPart, "#{bot.getNick()}, ") or (_.str.startsWith commandPart, "#{bot.getNick()}: ")
			nickUsage = true
			commandPart = commandPart.substring(bot.getNick().length + 2)
		
		serverName = bot.conn.opt.server
		isChannel = 0 is to.indexOf "#"

		for moduleName, module of @modules
			if not nickUsage
				continue if not _.str.startsWith commandPart, module.commandPrefix

				command = commandPart.substring module.commandPrefix.length

			else command = commandPart

			do (moduleName, module) =>

				routeToMatch = module.router.match command.split('%').join('%25') # Router doesn't like %'s
				if routeToMatch?
					origin =
						bot: bot
						user: from
						channel: if to is bot.getNick() then undefined else to
						isPM: to is bot.getNick()

					promise = Q(yes)

					if module.routerPerms[routeToMatch.route]?
						promise = Q.ninvoke module, 'hasPermission', origin, module.routerPerms[routeToMatch.route]

					promise.then (matched) =>
						if matched
							@canModuleRoute module, serverName, to, origin.isPM, ->
								try
									routeToMatch.fn origin, routeToMatch
								catch e
									console.error "Your module is bad and you should feel bad:"
									console.error e.stack
									
					.fail (err) => console.log err.stack



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

	registerApi: (module, api) ->
		if @apiMap[module] and Q.isPromise @apiMap[module].promise
			@apiMap[module].resolve api
		else
			@apiMap[module] = api

	apiCall: (module, callback) ->

		isNewApi = module not of @apiMap

		@apiMap[module] = Q.defer() if isNewApi

		promiseOrValue = if isNewApi then @apiMap[module].promise else @apiMap[module]

		Q.when promiseOrValue, (value) ->
			callback value


exports.ModuleManager = ModuleManager