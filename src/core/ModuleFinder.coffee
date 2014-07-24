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

kureaModuleFilter = minimatch.filter 'kurea-*', matchBase: yes

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

	for m in fs.readdirSync(baseModulesPath) when kureaModuleFilter m
		modules.push m

	modules

exports.loadFile = (file, moduleManager) ->
	fileModules = {}
	try
		{Module} = require './Module'
		classes = require(file)(Module)

		if not classes? then return

		classes = [].concat classes # So whatever is returned, is made into an array

		fileModules[clazz.name] = new clazz(moduleManager) for clazz in classes

	catch e
		console.log "There was a problem while loading #{file}"
		console.error e.stack

	fileModules

exports.loadCoreModules = (moduleManager) ->
	coreModules = {}

	file.walkSync coreModulesPath, (start, dirs, files) ->
		for f in (files.map (f) -> start+path.sep+f)
			_.extend coreModules, (exports.loadFile f, moduleManager)

	exports.modules['__core'] = coreModules

exports.loadModule = (mod, moduleManager) ->

exports.unloadModule = (mod) ->

exports.reloadModule = (mod) ->
	# unload, then load, simple as that
	exports.unloadModule mod
	exports.loadModule mod

exports.buildModuleList = (moduleManager) ->
	exports.loadCoreModules moduleManager

	# moduleNames = exports.findModules()

	# for m in moduleNames
	# 	exports.loadModule m

	exports.modules