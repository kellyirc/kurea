_ = require 'underscore'
path = require 'path'
file = require 'file'

Bot = require('./Bot').Bot
ModuleManager = require('./ModuleManager').ModuleManager
PermissionManager = require('./PermissionManager').PermissionManager

class BotManager
	constructor: (@config) ->
		if typeof @config is "string"
			@config = require path.resolve @config

		@bots = []
		@permissionManager = new PermissionManager()
		@userManagerClasses = @loadUserManagers __dirname + '/../auths'

		globalConfig = _.omit(@config, 'bots')
		for botName, botConfig of @config.bots
			@bots.push new Bot @, _.extend({name: botName, auth: "nick"}, globalConfig, botConfig)

		@moduleManager = new ModuleManager @
		
	loadUserManagers: (path) ->
		managerClasses = {}

		file.walkSync path, (start, dirs, files) ->
			for f in (files.map (f) -> start+'/'+f)
				auth = require f
				managerClasses[auth.name] = auth.AuthClass
				console.log "Added ", auth.name

		managerClasses

exports.BotManager = BotManager
