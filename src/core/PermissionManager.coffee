getPermissions = (user) ->
	perms =
		KR: ["*"]

	perms[user] ? []

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

exports.PermissionManager = PermissionManager
exports.manager = new PermissionManager()
exports.getPermissions = getPermissions