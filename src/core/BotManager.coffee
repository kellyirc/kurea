_ = require 'underscore'
path = require 'path'
Bot = require('./Bot').Bot
ModuleManager = require('./ModuleManager').ModuleManager
PermissionManager = require('./PermissionManager').PermissionManager

class BotManager
	constructor: (@config) ->
		if typeof @config is "string"
			@config = require path.resolve(@config)

		@bots = []
		@moduleManager = new ModuleManager()
		@permissionManager = new PermissionManager()

		globalConfig = _.omit(@config, 'bots')
		for botName, botConfig of @config.bots
			@bots.push new Bot(@, _.extend({name: botName}, globalConfig, botConfig))

exports.BotManager = BotManager