Router = require "routes"
ModuleDatabase = require('./ModuleDatabase').ModuleDatabase
EventEmitter = require('events').EventEmitter
UserInformationManager = require('./UserInformationManager').UserInformationManager
Q = require 'q'
fs = require 'fs'

class Module

	shortName: "Unnamed"
	helpText:
		default: "There is no help text for this module."
	usage:
		default: "There is no usage text for this module."

	commandPrefix: "!"

	suppressFailMessages: false

	userInformationManager: new UserInformationManager()

	constructor: (@moduleManager) ->
		@router = new Router()
		@routerPerms = {}
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

	setUserData: (origin, key, data, callback) ->
		@originToAuthName origin, (user) =>
			@userInformationManager.setData origin.bot.config.server, @shortName, user, key, data, callback

	getUserData: (origin, key, callback) ->
		@originToAuthName origin, (user) =>
			@userInformationManager.getData origin.bot.config.server, @shortName, user, key, callback

	originToAuthName: (origin, callback) ->
		origin.bot.userManager.getUsername origin, (e, username) =>
			callback username if username?
			@reply origin, "You must be logged in to #{origin.bot.config.auth} to use this command!" if not username and not @suppressFailMessages

	destroy: ->
		@events.forEach (element) =>
			@moduleManager.removeListener element.event, element.listener

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

	addRoute: (path, perm, fn) =>
		[fn, perm] = [perm, null] if not fn?

		@router.addRoute path, fn

		if perm?
			@routerPerms[path] = perm

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

exports.Module = Module