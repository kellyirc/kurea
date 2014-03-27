fs = require 'fs'
path = require 'path'
_ = require 'underscore'
_.str = require 'underscore.string'
file = require 'file'
watch = require 'watch'

config = require '../../config.json'

moduleFiles = {}
modules = {}

basePath = __dirname+'/../modules'

isInSubfolder = (folder, file) ->
	[folder, file] = [(path.resolve folder), (path.resolve file)]
	(file.indexOf folder) is 0

getIrcModuleOwner = (file) ->
	fullfile = require.resolve file
	fileModule = require.cache[fullfile]
	while fileModule?
		return fileModule.parent if fileModule.parent.filename of moduleFiles
		fileModule = fileModule.parent

	return null

removeNodeModule = (file) ->
	fullfile = require.resolve file
	fileModule = require.cache[fullfile]

	# console.log "Removing node.js module #{fileModule.filename}"

	for childModule in fileModule.children
		if isInSubfolder (path.dirname file), childModule.filename
			removeNodeModule childModule.filename

	# Remove children from file's module obj
	# for childModule in fileModule.children
	# 	childModule.parent = null
	# fileModule.children = []

	# Remove file's module obj from parent's children array
	i = fileModule.parent.children.indexOf fileModule
	fileModule.parent.children[i..i] = [] if ~i

	# Remove this file from cache
	delete require.cache[fullfile]

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
	if config.ignoredModules? and (path.basename file,'.coffee') in config.ignoredModules
		console.log "--- IGNORING #{path.basename file,'.coffee'}"
		return

	moduleFiles[file] = reloadFileModules file, moduleManager
	for moduleName, module of moduleFiles[file]
		modules[moduleName] = module

	console.log "--- Loaded [#{(m.shortName for name, m of moduleFiles[file]).join(', ')}]"

removeFile = (file, callback) ->
	file = path.resolve(file)

	console.log "--- Removing [#{(m.shortName for name, m of moduleFiles[file]).join(', ')}]"

	removeNodeModule file

	allDone = ->
		delete moduleFiles[file]
		callback?()

	done = _.after Object.keys(moduleFiles[file]).length, allDone

	for moduleName, module of moduleFiles[file]
		async = no

		delete modules[moduleName]
		module.destroy ->
			async = yes
			return done

		done() if not async

buildModuleList = (moduleManager) ->
	endsWithModule = (file) -> (_.str.endsWith (path.basename(file, path.extname(file))), 'Module')

	file.walkSync basePath, (start, dirs, files) ->
		for f in (files.map (f) -> start+path.sep+f)
			loadFile f, moduleManager if (endsWithModule f)

	options =
		interval: 2000
		filter: (f, stat) ->
			keep = (
				stat.isDirectory() or
				(
					(path.extname(f) in [".coffee"])
				)
			)

			not keep

	watch.createMonitor basePath, options, (monitor) ->
		monitor.on 'created', _.debounce( (f, stat) ->
			# console.log f, "created"
			if (endsWithModule f)
				loadFile f, moduleManager

			# Otherwise, if a non-module file was added, it makes no sense to do anything
				# If no module files were changed, whatever file was added is not related to any module at all, so do nothing
				# If a module file was changed to require the new non-module file, 'changed' handler reloads the module
		, 100)

		monitor.on 'changed', _.debounce( (f, currstat, prevstat) ->
			# console.log f, "changed"

			if (endsWithModule f)
				removeFile f, ->
					# console.log "Removed all from #{f}"
					loadFile f, moduleManager

			else
				# Non-module file was changed; find the module that require'd it, and reload THAT one
				# Children will be taken care of in the process
				m = getIrcModuleOwner f
				if m?
					# Reload dat module!!
					removeFile m.filename, ->
						# console.log "Removed all from #{m.filename}"
						loadFile m.filename, moduleManager

				# Else well, it's not related to any file existing already, so just do nothing
		, 100)

		monitor.on 'removed', _.debounce( (f, stat) ->
			# console.log f, "removed"
			if (endsWithModule f)
				removeFile f

			# removeFile takes care of the rest in the process
		, 100)
		
	modules

exports.buildModuleList = buildModuleList
