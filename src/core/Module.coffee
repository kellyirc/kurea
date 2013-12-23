Router = require "routes"
ModuleDatabase = require('./ModuleDatabase').ModuleDatabase
EventEmitter = require('events').EventEmitter
Q = require 'q'
fs = require 'fs'

class Module
	constructor: (@moduleManager) ->
		@router = new Router()
		@events = []

		if fs.existsSync "settings/#{@shortName}.json"
			_settings = JSON.parse (fs.readFileSync "settings/#{@shortName}.json"), {encoding: 'utf-8'}

		_settings ?= {}

		@settings =
			set: (key, value) =>
				_settings[key] = value
				@settings.save()

			get: (key) => _settings[key]

			save: () =>
				fs.mkdirSync "settings" if not fs.existsSync "settings"
				fs.writeFileSync "settings/#{@shortName}.json", JSON.stringify _settings

	destroy: ->
		@events.forEach (element) =>
			@moduleManager.removeListener element.event, element.listener
		delete @

	disable: (server, channel) =>
		@moduleManager.disableModule @, server, channel

	enable: (server, channel) =>
		@moduleManager.enableModule @, server, channel

	getBotManager: -> @moduleManager.botManager

	getApiKey: (name) -> @getBotManager().config.apiKeys[name]

	newDatabase: (name) =>
		new ModuleDatabase @shortName, name

	emit: (args...) ->
		@moduleManager.emit args...

	on: (event, listener) ->
		@moduleManager.on event,listener
		@events.push {event: event, listener: listener}

	addListener: (event, listener) ->
		@on event, listener

	once: (event, listener) ->
		@moduleManager.once event, listener

	removeListener: (event, listener) ->
		index = @events.length - 1
		while index >= 0
			e = @events[index]
			if e.event is event and e.listener is listener
				@moduleManager.removeListener event, listener
				@events.splice index, 1
				break
			index--

	removeAllListeners: (event) ->
		index = @events.length - 1
		while index >= 0
			e = @events[index]
			if e.event is event
				@moduleManager.removeListener e.event, e.listener
				@events.splice index, 1
			index--

	addRoute: (path, fn) =>
		@router.addRoute path, fn

	hasPermission: (origin, permission, callback) =>
		# request a match check to the PermissionManager in ModuleManager
		origin.bot.botManager.permissionManager.match origin, permission, callback

	reply: (origin, msg) ->
		if not origin.isPM
			origin.bot.say origin.channel, msg
		else
			origin.bot.say origin.user, msg

	getApi: () ->
		@api = { } if not @api

		@api

	registerApi: () ->
		@moduleManager.registerApi @shortName, @getApi()

	shortName: "Unnamed"
	helpText:
		default: "There is no help text for this module."

	commandPrefix: "!"

	#TODO make this a promise
	#isModuleActive: (bot, channel) ->


exports.Module = Module