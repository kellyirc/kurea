Router = require "routes"
ModuleDatabase = require('./ModuleDatabase').ModuleDatabase

class Module
	constructor: () ->
		@router = new Router()

	newDatabase: (name) =>
		new ModuleDatabase @shortName, name

	addRoute: (path, fn) =>
		@router.addRoute(path, fn)

	hasPermission: (origin, permission, callback) =>
		# request a match check to the PermissionManager in ModuleManager
		origin.bot.botManager.permissionManager.match(origin, permission, callback)

	reply: (origin, msg) ->
		if not origin.isPM
			origin.bot.say origin.channel, msg
		else
			origin.bot.say origin.user, msg

	shortName: "Unnamed"
	helpText:
		default: "There is no help text for this module."

exports.Module = Module