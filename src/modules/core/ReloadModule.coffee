module.exports = (Module) ->

	class ReloadModule extends Module
		shortName: 'Reload'

		helpText:
			default: 'I\'ll reload modules by myself if needed! Or, you can reload manually!'
			'reload': 'Reload a specified module manually!'

		usage:
			'reload': 'reload [moduleName (the name of the module\'s folder in node_modules/ ATM)]'

		constructor: (moduleManager) ->
			super