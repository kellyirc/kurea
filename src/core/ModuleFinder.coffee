fs = require 'fs'
path = require 'path'
# _ = require 'underscore'
# _.str = require 'underscore.string'
# file = require 'file'
# watch = require 'watch'
minimatch = require 'minimatch'

config = require '../../config.json'

baseModulesPath = __dirname+'/../../node_modules'

kureaModuleFilter = minimatch.filter 'kurea-*', matchBase: yes

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

exports.findModules = (nodeModulesPath) ->
	modules = {}

	for module in fs.readdirSync(basePath) when kureaModuleFilter module
		modules[module] = require.resolve module

	modules

exports.loadModule = (mod) ->

exports.unloadModule = (mod) ->

exports.reloadModule = (mod) ->
	# unload, then load, simple as that
	exports.unloadModule mod
	exports.loadModule mod

exports.buildModuleList = (moduleManager) ->
