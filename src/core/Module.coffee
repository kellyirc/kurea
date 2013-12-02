ModuleDatabase = require('./ModuleDatabase').ModuleDatabase

class Module
	constructor: () ->
		@commands = []

	newDatabase: (name) =>
		new ModuleDatabase @shortName, name

	hasPermission: (bot, user, permission) =>
		# request a match check to the PermissionManager in ModuleManager
		bot.botManager.permissionManager.match(user, permission)

	hasCommand: (command) =>
		command in @commands

	# The args object contains: bot, channel, user, command, params
	useCommand: (args) =>
		# should be overridden to handle command usage

exports.Module = Module