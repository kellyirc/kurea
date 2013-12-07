class PermissionManager
	constructor: () ->

	match: (origin, permissionString) ->
		permissionSet = @getPermissions(origin)

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

	getPermissions = (origin) ->
		username = origin.bot.userManager.getUsername(origin)

		perms =
			KR: ["*"]

		perms[username] ? []

exports.PermissionManager = PermissionManager