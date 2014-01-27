path = require 'path'
fs = require 'fs'
_ = require 'underscore'
_.str = require 'underscore.string'
CoffeeScript = require 'coffee-script'

getJsSource = (file) ->
	file = path.resolve file
	contents = fs.readFileSync file, encoding: 'utf-8'

	switch path.extname file
		when '.js' then return contents

		when '.coffee', '.lit-coffee', '.coffee.md'
			console.log "Compiling Coffeescript file..."

			try
				return CoffeeScript.compile contents, filename: file
			catch e
				console.error e.stack

walkFolder = (folder, callback) ->
	fs.readdir folder, (err, files) ->
		if err?
			callback err
			return

		for file in files
			fullPath = path.resolve folder, file

			do (file, fullPath) ->
				fs.stat fullPath, (err, stats) ->
					if err?
						callback err
						return

					if stats.isDirectory()
						walkFolder fullPath, callback

					else if stats.isFile()
						callback null, fullPath

exports.load = (folder, callback) ->
	walkFolder folder, (err, file) ->
		if err? then console.error err.stack

		console.log "Got file #{file}" if _.str.endsWith file, '.coffee'