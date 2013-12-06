_ = require 'underscore'
path = require 'path'
file = require 'file'

Bot = require('./Bot').Bot
ModuleManager = require('./ModuleManager').ModuleManager
PermissionManager = require('./PermissionManager').PermissionManager

class BotManager
	constructor: (config) ->
		if typeof config is "string"
			config = require path.resolve(config)
		config.default ?= {}

		@bots = []
		@moduleManager = new ModuleManager()
		@permissionManager = new PermissionManager()
		@userManagerClasses = @loadUserManagers(__dirname + '/../auths')

		for key, value of config when key isnt "default"
			@bots.push new Bot(@, _({name: key, auth: "nickserv"}).extend(config.default, value))

	loadUserManagers: (path) ->
		managerClasses = {}

		file.walkSync path, (start, dirs, files) ->
			for f in (files.map (f) -> start+'\\'+f)
				auth = require f
				managerClasses[auth.name] = auth.AuthClass
				console.log "Added ", auth.name

		managerClasses

exports.BotManager = BotManager