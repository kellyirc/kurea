fs = require 'fs'
_ = require 'underscore'
file = require 'file'

moduleFiles = []
modules = {}

basePath = __dirname+'/../modules'

file.walkSync basePath, (start, dirs, files) ->
	moduleFiles.push (files.map (f) -> start+'\\'+f)...

reloadFileModules = (file) ->
	fileModules = {}

	moduleContainerObject = require file
	for k of moduleContainerObject
		fileModules[k] = new moduleContainerObject[k] if k.indexOf 'Module' isnt -1

	fileModules

watchFile = (file) ->
	
	modules[file] = reloadFileModules file
	
	fs.watchFile file, _.debounce ((event, filename) ->
		delete require.cache[require.resolve file]
		delete modules[file]
		modules[file] = reloadFileModules file
	), 200



moduleFiles.forEach (f) ->
	watchFile f

exports.ModuleList = modules