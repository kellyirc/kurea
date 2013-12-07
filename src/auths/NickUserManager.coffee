UserManager = require('../core/UserManager').UserManager

class NickUserManager extends UserManager
	shortName: "nick"

	getUsername: (origin) ->
		console.log "Inside of NickUserManager!!"
		return origin.user

exports.name = NickUserManager::shortName
exports.AuthClass = NickUserManager