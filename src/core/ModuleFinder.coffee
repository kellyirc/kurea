fs = require 'fs'
path = require 'path'
_ = require 'underscore'
_.str = require 'underscore.string'
file = require 'file'
watch = require 'watch'

moduleFiles = {}
modules = {}

basePath = __dirname+'/../modules'

reloadFileModules = (file, moduleManager) ->
	fileModules = {}
	try
		Module = require('./Module').Module
		classes = require(file)(Module)

		if not classes? then return

		classes = [].concat classes # So whatever is returned, is made into an array

		fileModules[clazz.name] = new clazz(moduleManager) for clazz in classes

	catch e
		console.log "There was a problem while loading #{file}"
		console.error e.stack

	fileModules

loadFile = (file, moduleManager) ->
	file = path.resolve(file)

	moduleFiles[file] = reloadFileModules file, moduleManager
	for moduleName, module of moduleFiles[file]
		modules[moduleName] = module

	console.log "--- Loaded [#{(m.shortName for name, m of moduleFiles[file]).join(', ')}]"

removeFile = (file) ->
	file = path.resolve(file)

	console.log "--- Removing [#{(m.shortName for name, m of moduleFiles[file]).join(', ')}]"

	delete require.cache[require.resolve file]
	for moduleName, module of moduleFiles[file]
		delete modules[moduleName]
		module.destroy()
	delete moduleFiles[file]

buildModuleList = (moduleManager) ->
	file.walkSync basePath, (start, dirs, files) ->
		for f in (files.map (f) -> start+path.sep+f)
			loadFile f, moduleManager

	options =
		interval: 2000
		filter: (f, stat) ->
			not (stat.isDirectory() or path.extname(f) in [".coffee"])

	watch.createMonitor basePath, options, (monitor) ->
		monitor.on 'created', _.debounce( (f, stat) ->
			# console.log f, "created"
			loadFile f, moduleManager
		, 100)

		monitor.on 'changed', _.debounce( (f, currstat, prevstat) ->
			# console.log f, "changed"
			removeFile f
			loadFile f, moduleManager
		, 100)

		monitor.on 'removed', _.debounce( (f, stat) ->
			# console.log f, "removed"
			removeFile f
		, 100)
		
	modules

exports.buildModuleList = buildModuleList
