module.exports = (Module) ->
	url = require 'url'
	path = require 'path'
	childProcess = require 'child_process'
	util = require 'util'

	_ = require 'underscore'
	_.str = require 'underscore.string'
	npm = require 'npm'
	npa = require 'npm-package-arg'
	Q = require 'q'

	ModuleFinder = require('../../core/ModuleFinder')

	pick = (object, callback) ->
		_.pick object, (k for k,v of object when callback v, k, object)
	
	class PackageManagerModule extends Module
		shortName: 'PackageManager'
		helpText:
			default: 'Manage packages!'
			'check-update': 'Check for updates manually'
		usage:
			'check-update': 'check-update'
		  
		constructor: (moduleManager) ->
			super

			@addRoute 'check-update', (origin, route) =>
				@reply origin, 'Checking for updates...'

				@checkUpdates()

				.then (modules) =>
					# console.log modules
					# data for name, data of modules when data.needsUpdate
					modules.filter (data) -> data.needsUpdate

				.then (modules) =>
					@reply origin, "Modules [#{(m.name for m in modules)}] needs to be updated!"

					modules

				.then (modules) => @updateManyModules modules

				.done =>
					@reply origin, "Done updating modules."

				, (err) =>
					console.error err.stack
					@reply origin, "Uh oh, problem! #{err}"

			npm.load (err, npm) =>
				if err?
					console.error 'Failed to load npm configs, package manager won\'t work'
					console.error err.stack

				else
					console.log 'Loaded npm config info'

		###
		Promise-fied functions
		###
		exec: Q.nfbind childProcess.exec

		npmInstall: (args...) -> Q.ninvoke npm.commands, 'install', args...

		###
		Utility functions
		###
		getKureaModules: ->
			modules = _.filter (_.keys @moduleManager.modules),
				(s) -> not _.str.startsWith s, '__'

			Q.ninvoke(npm.commands, 'ls', [], yes)

			.then ([data, liteData]) ->
				data.dependencies[dep] for dep in modules

		determineUpdateSource: (from, resolved) ->
			if from?
				parsedFrom = npa from

				return switch parsedFrom.type
					when 'git'
						parsedUrl = url.parse parsedFrom.spec
						parsedUrl.hash = ''

						type: 'git'
						repoUrl: url.format parsedUrl
						commitHash: url.parse(resolved).hash.substr(1)

					when 'version', 'range', 'tag'
						type: 'npm'
						name: parsedFrom.name
						specType: parsedFrom.type
						spec: parsedFrom.spec

					else
						type: 'unknown'

			else
				return type: 'unknown'

		gitLsRemote: (gitUrl, refs) ->
			@exec("git ls-remote #{gitUrl} #{refs.join ' '}")

			.then ([stdout, stderr]) ->
				pattern = /^([a-z0-9]+?)\s+(.+?)$/img
				while (match = pattern.exec stdout)?
					name: match[2]
					hash: match[1]

			.then (names) ->
				_.indexBy names, 'name'

		###
		Checking for updates
		###
		checkUpdates: (callback) =>
			Q.fcall ->
				throw new Error 'npm not yet loaded' if not npm.config.loaded

				console.log 'Npm is loaded'

			.then => @getKureaModules()

			.then (modules) =>
				for modData in modules
					name: modData.name
					data: modData
					source: @determineUpdateSource modData._from, modData._resolved
					installWhere: path.resolve modData.realPath, '..', '..'

			.then (modules) =>
				Q.all [
					Q modules
					Q.all (@checkUpdateSingle m for m in modules)
				]

			.then ([modules, result]) ->
				for mod, i in modules
					mod.needsUpdate = result[i]

				modules

		checkUpdateSingle: (module) ->
			Q.fcall =>
				switch module.source.type
					when 'git' then @checkUpdateGit module

					else no

		checkUpdateGit: (module) ->
			console.log "Checking #{module.source.repoUrl}"

			@gitLsRemote(module.source.repoUrl, ['HEAD'])

			.then (reply) ->
				[current, latest] = [module.source.commitHash, reply.HEAD.hash]

				console.log "#{module.source.repoUrl}:"
				console.log "--- #{current}"
				console.log "--- #{latest}"

				current isnt latest

		###
		Updating
		###
		updateManyModules: (modules) ->
			p = Q.all(@updateModule m for m in modules)

		updateModule: (module) ->
			Q.fcall => Q.ninvoke @moduleManager, 'unloadModule', module.name

			# .then -> console.log "Installing #{module.name}...."

			.then => @npmInstall(module.installWhere, [module.data._from])

			# .then -> console.log "Done installing #{module.name}!!!"

			.then => @moduleManager.loadModule(module.name, @moduleManager)
	
	PackageManagerModule