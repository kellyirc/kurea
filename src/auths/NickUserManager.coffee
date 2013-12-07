UserManager = require('../core/UserManager').UserManager

class NickUserManager extends UserManager
	shortName: "nick"

	getUsername: (origin, callback) ->
		console.log "Inside of NickUserManager!!"
		
		callback(null, origin.user)

exports.name = NickUserManager::shortName
exports.AuthClass = NickUserManager