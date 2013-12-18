
fs = require 'fs'
if fs.existsSync '../../config.json'
	config = require '../../config.json'
	databaseEngine = config.storage
	databaseURL = config.storageURL

#more info here: https://github.com/louischatriot/nedb/blob/master/README.md
Database = if databaseEngine is 'mongo' then require('mongodb').MongoClient else require 'nedb'
rimraf = require 'rimraf'

class ModuleDatabase

	load: () =>
		if not @label?.length then throw new Error "Database must have a name."
		if not @root?.length then throw new Error "Module must have a shortName of length 1 or greater."

		if databaseEngine is 'mongo'
			if not ModuleDatabase::databaseConnection
				Database.connect "mongodb://#{databaseURL}/kurea", {server:{auto_reconnect:true}}, (e, db) =>
					throw e if e?

					ModuleDatabase::databaseConnection = db
			
					@db = ModuleDatabase::databaseConnection.collection "#{@root}_#{@label}"
			else
				@db = ModuleDatabase::databaseConnection.collection "#{@root}_#{@label}"

		#use nedb by default because it's a better assumption to make
		else
			path = "data/#{@root}/#{@label}.kdb"
			@db = new Database { autoload: true, filename: path }

	insert: (data, callback) =>
		@db.insert data, callback

	remove: (query, options, callback) =>
		@db.remove query, options, callback

	count: (data, callback) =>
		@db.count data, callback

	update: (query, update, options, callback) =>
		@db.update query, update, options, callback

	find: (terms, callback) =>
		@db.find terms, callback

	ensureIndex: (data, callback) =>
		@db.ensureIndex data, callback

	destroy: (callback) =>
		return if databaseEngine is 'mongo'
		callback ?= ->
		rimraf @db.filename, callback

	constructor: (@root, @label) ->
		#gotta think of a way to include versioning and migrating
		@version = 0
		@load()

exports.ModuleDatabase = ModuleDatabase