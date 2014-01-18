
ModuleDatabase = require('./ModuleDatabase').ModuleDatabase

class UserInformationManager

	userInfo: new ModuleDatabase 'internal', 'user-info'

	setData: (server, module, user, key, data, callback) ->

		updateObj =
			user: user
			server: server

		updateObj[module] = {}
		updateObj[module][key] = data

		@userInfo.update { user: user, server: server }, updateObj, { upsert: true }, ->
			callback?()

	getData: (server, module, user, key, callback) ->

		@userInfo.find { user: user, server: server }, (e, doc) ->
			callback doc[0]?[module]?[key]

exports.UserInformationManager = UserInformationManager