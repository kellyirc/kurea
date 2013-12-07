UserManager = require('../core/UserManager').UserManager

class NickServUserManager extends UserManager
	shortName: "nickserv"

	getUsername: (origin, callback) ->
		console.log "Inside of NickServUserManager!!"

		# username = null
		# origin.bot.whois origin.user, (info) ->
		# 	console.log "Got the info, it's #{info.account}"
		# 	username = info.account

		callback(null, origin.user)

exports.name = NickServUserManager::shortName
exports.AuthClass = NickServUserManager