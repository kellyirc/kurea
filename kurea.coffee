
Database = require 'nedb'
fs = require 'fs'

class ModuleDatabase

	dataStoreFolder = 'data'

	load: () =>
		if not @label?.length then throw new Error("Database must have a name.")
		if not @root?.length then throw new Error("Module must have a shortName of length 1 or greater.")

		@path = "#{dataStoreFolder}/#{@root}/#{@label}.kdb"
		@db = new Database { autoload: true, filename: @path }

	insert: (data, callback) =>
		@db.insert data, callback

	remove: (query, options, callback) =>
		@db.remove query, options, callback

	count: (data, callback) =>
		@db.count data, callback

	update: (query, update, options, callback) =>
		@db.update query, update, options, callback

	find: (terms, callback) =>
		@db.find terms, callback

	ensureIndex: (data, callback) =>
		@db.ensureIndex data, callback

	destroy: () =>
		fs.unlink @path

	constructor: (@root, @label) ->
		#gotta think of a way to include versioning and migrating
		@version = 0
		@load()

exports.ModuleDatabase = ModuleDatabase
ModuleDatabase = ModuleDatabase || require('./ModuleDatabase').ModuleDatabase

class Module
	constructor: () ->

	newDatabase: (name) =>
		new ModuleDatabase @shortName,name

exports.Module = Module
getPermissions = (user) ->
	if user is 'CoolDude210' then ["access.get", "userdata"]
	else if user is 'CakeRox' then ["*"]

class PermissionManager
	constructor: () ->

	match: (user, permissionString) ->
		permissionSet = getPermissions(user)
		for permission in permissionSet
			if @matchPermissions(permission, permissionString) then return true

		false

	matchPermissions: (permission, permissionToMatch) ->
		if permission is '*' or permissionToMatch is '*' then return true

		until permissionToMatch is null
			if permissionToMatch is permission then return true

			permissionToMatch = @getParent(permissionToMatch)

		false

	getParent: (permission) ->
		if (lastDot = permission.lastIndexOf '.') >= 0
			return permission.substring 0, lastDot

		null

module.exports.PermissionManager = PermissionManager
module.exports.manager = new PermissionManager()
module.exports.getPermissions = getPermissions