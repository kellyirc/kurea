
fs = require 'fs'
Q = require 'q'

if fs.existsSync 'config.json'
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

		_isReady = Q.defer()
		@databaseReady = _isReady.promise

		if databaseEngine is 'mongo'
			if not ModuleDatabase::databaseConnection
				Database.connect "mongodb://#{databaseURL}/kurea", {server:{auto_reconnect:true}}, (e, db) =>
					#_isReady.error e if e?
					throw e if e?

					ModuleDatabase::databaseConnection = db
			
					@db = ModuleDatabase::databaseConnection.collection "#{@root}_#{@label}"

					_isReady.resolve @db
			else
				@db = ModuleDatabase::databaseConnection.collection "#{@root}_#{@label}"

		#use nedb by default because it's a better assumption to make
		else
			path = "data/#{@root}/#{@label}.kdb"
			@db = new Database { autoload: true, filename: path }
			_isReady.resolve @db

	insert: (data, callback) =>
		@db.insert data, callback

	remove: (query, options, callback) =>
		if databaseEngine is 'mongo'
			@db.remove query, {w:0}
		else
			@db.remove query, options, callback

	count: (data, callback) =>
		@db.count data, callback

	update: (query, update, options, callback) =>
		@db.update query, update, options, callback

	find: (terms, callback) =>
		if databaseEngine is 'mongo'
			@db.find terms, (e, docs) ->
				docs.toArray callback
		else
			@db.find terms, callback

	findForEach: (terms, callback) =>
		if databaseEngine is 'mongo'
			Q.when @databaseReady, (db) ->
				db.find(terms).stream().on 'data', (data) -> callback null, data
		else
			@db.find terms, (e, docs) ->
				docs.forEach (doc) ->
					callback e, doc

	ensureIndex: (data, callback) =>
		@db.ensureIndex data, callback

	# TODO: remove this when nedb adds sorting which should be soon
	# Sorts documents by given properties to compare.
	# Each property in the object should either be
	# 1 for ascending or -1 for descending order.
	# Example compareProps = {name: 1, age: -1}
	# Will sort by name alphabetically, then age oldest first
	sort: (docs, compareProps) ->
		docs.sort (a, b) ->
			for prop, order of compareProps
				if a[prop] < b[prop]
					return -order
				if a[prop] > b[prop]
					return order
			return 0


	destroy: (callback) =>
		return if databaseEngine is 'mongo'
		callback ?= ->
		rimraf @db.filename, callback

	constructor: (@root, @label) ->
		#gotta think of a way to include versioning and migrating
		@version = 0
		@load()

exports.ModuleDatabase = ModuleDatabase