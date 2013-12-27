UserManager = require('../core/UserManager').UserManager

class NickServUserManager extends UserManager
	shortName: "nickserv"

	getUsername: (origin, callback) ->

		origin.bot.whois origin.user, (info) ->
			callback(null, info.account)

exports.name = NickServUserManager::shortName
exports.AuthClass = NickServUserManager