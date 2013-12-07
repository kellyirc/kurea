fs = require 'fs'
path = require 'path'
_ = require 'underscore'
file = require 'file'

moduleFiles = {}
modules = {}

basePath = __dirname+'/../modules'

reloadFileModules = (file) ->
	fileModules = {}

	moduleContainerObject = require file
	for k of moduleContainerObject
		fileModules[k] = new moduleContainerObject[k] if k.indexOf 'Module' isnt -1

	fileModules

watchFile = (file) ->
	
	moduleFiles[file] = reloadFileModules file
	for moduleName, module of moduleFiles[file]
		modules[moduleName] = module

	fs.watchFile file, _.debounce ((event, filename) ->
		delete require.cache[require.resolve file]
		for moduleName, module of moduleFiles[file]
			delete module[moduleName]
		delete moduleFiles[file]

		moduleFiles[file] = reloadFileModules file
		for moduleName, module of moduleFiles[file]
			modules[moduleName] = module

		console.log "^--- Loaded [#{(m.shortName for name, m of moduleFiles[file]).join(', ')}] from #{path.resolve(file)}"
	), 200


file.walkSync basePath, (start, dirs, files) ->
	for f in (files.map (f) -> start+path.sep+f)
		watchFile f

exports.ModuleList = modules