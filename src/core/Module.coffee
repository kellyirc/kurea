
class Module

	newDatabase: (name) ->
		new ModuleDatabase @shortName,name

	constructor: () ->