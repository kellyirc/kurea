class UserManager
	constructor: ->

	getUsername: (origin, callback) ->
		# Should be overridden by subclasses depending on method used
		callback null, null

exports.UserManager = UserManager