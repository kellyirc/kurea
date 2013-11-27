ModuleDatabase = ModuleDatabase || require('./ModuleDatabase').ModuleDatabase

class Module
	constructor: () ->

	newDatabase: (name) =>
		new ModuleDatabase @shortName,name

exports.Module = Module