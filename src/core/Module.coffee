ModuleDatabase = require('./ModuleDatabase').ModuleDatabase

class Module
	constructor: () ->
		@commands = []

	newDatabase: (name) =>
		new ModuleDatabase @shortName, name

	hasPermission: (user, permission) =>
		# request a match check to the PermissionManager in ModuleManager

	hasCommand: (command) =>
		command in @commands

	# The args object contains: bot, channel, user, command, params
	useCommand: (args) =>
		# should be overridden to handle command usage

exports.Module = Module