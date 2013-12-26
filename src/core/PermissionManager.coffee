ModuleDatabase = require('./ModuleDatabase').ModuleDatabase
_ = require 'underscore'
Q = require 'q'

Q.longStackSupport = true

class PermissionManager
	constructor: () ->
		@db = new ModuleDatabase "internal", "permissions"

	match: (origin, permissionString, callback) ->
		@getPermissions origin, (err, permissionSet) =>
			if err?
				callback err
				return

			console.log "Permission set is:", permissionSet
			callback null, @matchSet(permissionSet, permissionString)

	matchSet: (permissionSet, permissionToMatch) ->
		for permission in permissionSet
			if @matchPermissions(permission, permissionToMatch) then return true

		false

	matchPermissions: (permission, permissionToMatch) ->
		if permission is '*' or permissionToMatch is '*' then return true

		until permissionToMatch is null
			if permissionToMatch is permission then return true

			permissionToMatch = @getParent permissionToMatch

		false

	getParent: (permission) ->
		if (lastDot = permission.lastIndexOf '.') >= 0
			return permission.substring 0, lastDot

		null

	getPermissions: (origin, callback) =>
		origin.bot.userManager.getUsername origin, (err, username) =>
			if err? then callback err
			else if not username? then callback new Error("No username was returned")

			else
				Q.all([
					Q.ninvoke(@db, 'find', { username: username.toLowerCase() })
						.then (docs) -> _.flatten (doc?.permissions for doc in docs)

					Q.ninvoke(@, 'getGroups', origin).then((groups) => Q.ninvoke @db, 'find', { group: { $in: groups } })
						.then (docs) -> _.flatten (doc?.permissions for doc in docs)
				])

				.then (perms) =>
					[userPerms, groupPerms] = perms
					console.log "User permissions:", userPerms
					console.log "Group permissions:", groupPerms

					# get data from @db.find for username and group
					callback null, _.flatten perms

				.fail (err) =>
					# failure handler
					console.log "Problem!!!", err
					callback err

	getGroups: (origin, callback) =>
		callback null, ["owner", "testing"]

	addPermission: (targetString, permission, callback) =>
		# Assuming target is nothing but username ATM...
		target = @parseTarget targetString
		console.log target
		# if not target.username?
		# 	callback new Error("No username specified")
		# 	return

		@db.update target, { $push: { permissions: permission } }, { upsert: true }, (err, replacedCount, upsert) =>
			if err? then callback err
			else callback null

	parseTarget: (targetString) =>
		target = {}

		regex = ///
			^
				([^.@].*?)?		# username
				(?:\.(.+?))?	# group
				(?:@(.+?))?		# server
			$
		///

		match = regex.exec targetString
		if match?
			console.log "Match fags", match
			[target.username, target.group, target.server] = [match[1] ? null, match[2] ? null, match[3] ? null]

		target

	dump: =>
		@db.find {}, (err, docs) =>
			if err? then console.error err.stack
			else
				for doc in docs
					console.log doc

exports.PermissionManager = PermissionManager
