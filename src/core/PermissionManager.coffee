ModuleDatabase = require('./ModuleDatabase').ModuleDatabase
_ = require 'underscore'
Q = require 'q'

Q.longStackSupport = true

class PermissionManager
	constructor: () ->
		@db =
			permissions: new ModuleDatabase "internal", "permissions"
			usergroups: new ModuleDatabase "internal", "usergroups"

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
			else if not username? then callback null, []

			else if username.toLowerCase() is origin.bot.config.owner then callback null, ['*']

			else
				# Q.all([
				# 	Q.ninvoke(@db.permissions, 'find', { username: username.toLowerCase() })
				# 		.then (docs) -> _.flatten (doc?.permissions for doc in docs)

				# 	Q.ninvoke(@, 'getGroups', origin.bot, username)
				# 		.then((groups) => Q.ninvoke @db.permissions, 'find', { group: { $in: groups } })
				# 		.then (docs) -> _.flatten (doc?.permissions for doc in docs)
				# ])
				Q.all([
					Q username
					Q.ninvoke @, 'getGroups', origin.bot, username
				])

				.then (data) =>
					[username, groups] = data

					userOrNull = (username) => { $or: [ { username: username.toLowerCase() }, { username: null } ] }
					inGroupOrNull = (groups) => { $or: [ { group: { $in: groups } }, { group: null } ] }

					Q.ninvoke @db.permissions, 'find',
						$and: [
							userOrNull username.toLowerCase()
							inGroupOrNull groups
							]

				.then (docs) =>
					_.flatten (doc?.permissions for doc in docs)

				.then (perms) =>
					console.log "Permissions:", perms

					# get data from @db.permissions.find for username and group
					callback null, perms

				.fail (err) =>
					# failure handler
					console.log "Problem!!!", err
					callback err

	addPermission: (targetString, permission, callback) =>
		target = @parseTarget targetString
		console.log target
		# if not target.username?
		# 	callback new Error("No username specified")
		# 	return

		@db.permissions.update target, { $push: { permissions: permission } }, { upsert: true }, (err, replacedCount, upsert) =>
			if err? then callback err
			else callback null

	getGroups: (bot, username, callback) =>
		Q.ninvoke( @db.usergroups, 'find', { username: username.toLowerCase(), server: bot.getName().toLowerCase() } )

		.then (docs) =>
			groups = _.flatten (docs[0]?.groups)
			console.log "Groups for user #{username} @ #{bot.getName()}:", groups
			callback null, groups

		.fail (err) => callback err

	addGroup: (bot, targetUsername, group, callback) =>
		@db.usergroups.update { username: targetUsername.toLowerCase(), server: bot.getName().toLowerCase() },
			{ $push: { groups: group } }, { upsert: true },

			(err, replacedCount, upsert) =>
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
		@db.permissions.find {}, (err, docs) =>
			if err? then console.error err.stack
			else
				for doc in docs
					console.log doc

exports.PermissionManager = PermissionManager
