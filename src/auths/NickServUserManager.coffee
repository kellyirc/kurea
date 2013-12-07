UserManager = require('../core/UserManager').UserManager

class NickServUserManager extends UserManager
	shortName: "nickserv"

	getUsername: (origin, callback) ->
		console.log "Inside of NickServUserManager!!"

		origin.bot.whois origin.user, (info) ->
			console.log "Got the info, it's #{info.account}"
			callback(null, info.account)

exports.name = NickServUserManager::shortName
exports.AuthClass = NickServUserManager