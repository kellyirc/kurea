
ModuleDatabase = require('./ModuleDatabase').ModuleDatabase

class UserInformationManager

	userInfo: new ModuleDatabase 'internal', 'user-info'

	setData: (server, module, user, key, data, callback) ->

		console.log "Calling setData from module #{module} with user #{user} and key #{key}"
		console.log "Data is", data

		updateObj = 
			user: user
			server: server

		updateObj[module] = {}
		updateObj[module][key] = data

		@userInfo.update { user: user, server: server }, updateObj, { upsert: true }, ->
			console.log "Inserted data"
			callback?()

	getData: (server, module, user, key, callback) ->

		console.log "calling get for #{user}"

		@userInfo.find { user: user, server: server }, (e, doc) ->
			console.log "inside get"
			console.log doc
			callback doc[0]?[module]?[key]


exports.UserInformationManager = UserInformationManager