fs = require 'fs'
path = require 'path'
_ = require 'underscore'
# _.str = require 'underscore.string'
file = require 'file'
# watch = require 'watch'
minimatch = require 'minimatch'

config = require '../../config.json'

coreModulesPath = "#{__dirname}/../modules"
modulesPath = "#{__dirname}/../../node_modules"

exports.kureaModuleFilter = minimatch.filter 'kurea-*', matchBase: yes

# The object that contains all loaded modules
exports.modules = {}

exports.removeNodeModule = (file) ->
	fullfile = require.resolve file
	fileModule = require.cache[fullfile]

	# console.log "Removing node.js module #{fileModule.filename}"

	return if not fileModule

	for childModule in fileModule.children
		removeNodeModule childModule.filename

		childModule.parent = null

	fileModule.children = []

	# Remove file's module obj from parent's children array
	i = fileModule.parent.children.indexOf fileModule
	fileModule.parent.children[i..i] = [] if ~i

	# Remove this file from cache
	delete require.cache[fullfile]

exports.findModules = ->
	modules = []

	for m in fs.readdirSync(modulesPath) when exports.kureaModuleFilter m
		modules.push m

	modules

exports.loadFile = (file, moduleManager) ->
	fileModules = {}

	{Module} = require './Module'
	classes = require(file)(Module)

	if not classes? then return

	classes = [].concat classes # So whatever is returned, is made into an array

	fileModules[clazz.name] = new clazz(moduleManager) for clazz in classes

	# console.log "Loaded [#{(clazz.name for clazz in classes).join ', '}] from #{file}"

	fileModules

exports.loadCoreModules = (moduleManager) ->
	coreModules = {}

	file.walkSync coreModulesPath, (start, dirs, files) ->
		for f in (files.map (f) -> start+path.sep+f)
			_.extend coreModules, (exports.loadFile f, moduleManager)

	exports.modules['__core'] = coreModules

	console.log 'Loaded core modules'

exports.loadModule = (mod, moduleManager) ->
	exports.modules[mod] = exports.loadFile (require.resolve mod), moduleManager

	console.log "Loaded external module '#{mod}' (#{require.resolve mod})"

exports.unloadModule = (mod, callback) ->
	exports.removeNodeModule mod

	allDone = ->
		delete exports.modules[mod]

		console.log "Unloaded external module '#{mod}' (#{require.resolve mod})"

		callback?()

	# invoke destroy func on every module before unloading !!
	done = _.after Object.keys(exports.modules[mod]).length, allDone

	for moduleName, m of exports.modules[mod]
		async = no

		enableAsync = ->
			async = yes
			return done

		m.destroy enableAsync

		done() if not async

exports.reloadModule = (mod, callback) ->
	# unload, then load, simple as that
	exports.unloadModule mod, (err) ->
		return callback? err if err?

		exports.loadModule mod
		callback?()

exports.buildModuleList = (moduleManager) ->
	exports.loadCoreModules moduleManager

	moduleNames = exports.findModules()

	for m in moduleNames
		exports.loadModule m, moduleManager

	exports.modules