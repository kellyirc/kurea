class UserManager
	constructor: ->

	getUsername: (origin) ->
		# Should be overridden by subclasses depending on method used
		console.log "Inside of UserManager!!"

exports.UserManager = UserManager