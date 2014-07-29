module.exports = (Module) ->
	chokidar = require 'chokidar'
	_ = require 'underscore'
	_.str = require 'underscore.string'

	class ReloadModule extends Module
		shortName: 'Reload'

		helpText:
			default: 'I\'ll reload modules by myself if needed! Or, you can reload manually!'
			'reload': 'Reload a specified module manually!'

		usage:
			'reload': 'reload [moduleName (the name of the module\'s folder in node_modules/ ATM)]'

		constructor: (moduleManager) ->
			super

			@watcher = chokidar.watch '.',
				persistent: yes
				ignoreInitial: yes
				ignored: (path) -> not (path is '.' or _.str.startsWith path, 'node_modules')
				usePolling: yes

				interval: 2000
				binaryInterval: 2000

			@changeQueue = {}

			triggerFileProcess = _.debounce =>
				for mod, changed of @changeQueue
					console.log "Reloading #{mod}!"
					moduleManager.reloadModule mod

				changeQueue = {}
			, 2000

			for e in ['add', 'change', 'unlink']
				do (e) =>
					@watcher.on e, (filename) =>
						[nodeModules, mod] = filename.split /[\\/]/

						if mod isnt '__core' and mod of moduleManager.modules
							console.log "Adding '#{mod}' to queue of modules to reload"
							@changeQueue[mod] = true
							triggerFileProcess()

			@watcher.on 'all', (event, filename) ->
				console.log {event, filename}

			@watcher.on 'error', (err) ->
				console.error 'Error in module watcher:', err.stack