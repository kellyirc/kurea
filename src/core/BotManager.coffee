_ = require 'underscore'
path = require 'path'
Bot = require('./Bot').Bot
ModuleManager = require('./ModuleManager').ModuleManager
PermissionManager = require('./PermissionManager').PermissionManager

class BotManager
	constructor: (config) ->
		if typeof config is "string"
			config = require path.resolve(config)
		unless config.default?
			config.default = {};

		@bots = []
		@moduleManager = new ModuleManager()
		@permissionManager = new PermissionManager()

		for key, value of config when key isnt "default"
			@bots.push new Bot(@, _({name: key}).extend(config.default, value))

exports.BotManager = BotManager