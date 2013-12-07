class PermissionManager
	constructor: () ->

	match: (origin, permissionString, callback) ->
		@getPermissions origin, (err, permissionSet) =>
			callback(null, @matchSet(permissionSet, permissionString))

	matchSet: (permissionSet, permissionToMatch) ->
		for permission in permissionSet
			if @matchPermissions(permission, permissionToMatch) then return true

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

	getPermissions: (origin, callback) ->
		perms =
			KR: ["access", "machinery.boat"]

		origin.bot.userManager.getUsername origin, (err, username) =>
			callback(null, perms[username] ? [])

exports.PermissionManager = PermissionManager