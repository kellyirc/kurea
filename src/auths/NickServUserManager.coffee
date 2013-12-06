UserManager = require('../core/UserManager').UserManager

class NickServUserManager extends UserManager
	shortName: "nickserv"

	getUsername: (origin) ->
		console.log "Inside of NickServUserManager!!"

		# username = null
		# origin.bot.whois origin.user, (info) ->
		# 	console.log "Got the info, it's #{info.account}"
		# 	username = info.account

		return origin.user

exports.name = NickServUserManager::shortName
exports.AuthClass = NickServUserManager