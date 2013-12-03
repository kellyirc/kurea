Router = require "routes"
ModuleDatabase = require('./ModuleDatabase').ModuleDatabase

class Module
	constructor: () ->
		@router = new Router()

	newDatabase: (name) =>
		new ModuleDatabase @shortName, name

	addRoute: (path, fn) =>
		@router.addRoute(path, fn)

	hasPermission: (bot, user, permission) =>
		# request a match check to the PermissionManager in ModuleManager
		bot.botManager.permissionManager.match(user, permission)

exports.Module = Module