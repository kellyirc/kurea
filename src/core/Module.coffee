ModuleDatabase = require('./ModuleDatabase').ModuleDatabase

class Module
	constructor: () ->

	newDatabase: (name) =>
		new ModuleDatabase @shortName,name

	hasPermission: (user, permission) =>
		# request a match check to the PermissionManager in ModuleManager

	# The args object contains: bot, channel, user, command, params
	useCommand: (args) =>
		# should be overridden to handle command usage

exports.Module = Module