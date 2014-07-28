module.exports = (Module) ->
	url = require 'url'
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

				.then (needsUpdate) =>
					console.log needsUpdate

					for name, data of needsUpdate when data.needsUpdate
						@reply origin, "Module #{name} needs to be updated!"

				.fail (err) =>
					console.error err.stack
					@reply origin, "Error: #{err}"

			npm.load (err, npm) =>
				if err?
					console.error 'Failed to load npm configs, package manager won\'t work'
					console.error err.stack
					return

		checkUpdates: (callback) =>
			Q.fcall ->
				throw new Error 'npm not yet loaded' if not npm.config.loaded

				console.log 'Npm is loaded'

			.then => @getKureaModules()

			# .then (modules) ->
			# 	console.log 'Got modules:'
			# 	console.log modules
			# 	modules

			.then (modules) =>
				for mod, modData of modules
					name: mod
					data: modData
					source: @determineUpdateSource modData.from, modData.resolved

			.then (modules) =>
				Q.all (@checkUpdateSingle m for m in modules)

			.then (result) ->
				_.reduce result, ((memo, cur) -> memo[cur[0]] = cur[1]; memo), {}

			.nodeify callback

		checkUpdateSingle: (module, callback) ->
			(
				switch module.source.type
					when 'git' then @checkUpdateGit module

					else Q no
			)
			.then (needsUpdate) ->
				module = _.clone module
				module.needsUpdate = needsUpdate
				[module.name, module]

			.nodeify callback

		checkUpdateGit: (module, callback) ->
			console.log "Checking #{module.source.repoUrl}"

			@gitLsRemote(module.source.repoUrl, ['HEAD'])

			.then (reply) ->
				[current, latest] = [module.source.commitHash, reply.HEAD.hash]

				console.log "#{module.source.repoUrl}:"
				console.log "--- #{current}"
				console.log "--- #{latest}"

				current isnt latest

			.nodeify callback

		exec: Q.nfbind childProcess.exec

		getKureaModules: (callback) ->
			modules = _.filter (_.keys @moduleManager.modules),
				(s) -> not _.str.startsWith s, '__'

			Q.ninvoke(npm.commands, 'ls', [], yes)

			.then ([data, liteData]) ->
				# _.pick liteData.dependencies, modules
				liteData.dependencies

			.nodeify callback

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

					else
						type: 'unknown'

			else
				return type: 'unknown'

		gitLsRemote: (gitUrl, refs, callback) ->
			@exec("git ls-remote #{gitUrl} #{refs.join ' '}")

			.then ([stdout, stderr]) ->
				pattern = /^([a-z0-9]+?)\s+(.+?)$/img
				while (match = pattern.exec stdout)?
					name: match[2]
					hash: match[1]

			.then (names) ->
				_.indexBy names, 'name'

			.nodeify callback
	
	PackageManagerModule