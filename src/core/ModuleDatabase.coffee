
Database = require 'nedb'
fs = require 'fs'
rimraf = require 'rimraf'

#more info here: https://github.com/louischatriot/nedb/blob/master/README.md
class ModuleDatabase

	dataStoreFolder = 'data'

	load: () =>
		if not @label?.length then throw new Error("Database must have a name.")
		if not @root?.length then throw new Error("Module must have a shortName of length 1 or greater.")

		path = "#{dataStoreFolder}/#{@root}/#{@label}.kdb"
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
		callback ?= ->
		rimraf @db.filename, callback

	constructor: (@root, @label) ->
		#gotta think of a way to include versioning and migrating
		@version = 0
		@load()

exports.ModuleDatabase = ModuleDatabase