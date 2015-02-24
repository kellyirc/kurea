module.exports = (Module) ->
	url = require 'url'
	fs = require 'fs'
	path = require 'path'
	childProcess = require 'child_process'
	util = require 'util'

	_ = require 'lodash'
	npm = require 'npm'
	npa = require 'npm-package-arg'
	semver = require 'semver'
	Q = require 'q'

	ModuleFinder = require('../../core/ModuleFinder')

	pick = (object, callback) ->
		_.pick object, (k for k,v of object when callback v, k, object)
	
	class PackageManagerModule extends Module
		shortName: 'PackageManager'
		helpText:
			default: 'Manage packages! Available subcommands: update, check-update, install, uninstall'
			'update': 'Update given package if needed, or all if no package given'
			'check-update': 'Check for updates manually'
			'install': 'Install a package (uses npm, supports all specs npm supports)'
			'uninstall': 'Uninstall a package'
		usage:
			'update': 'update {nodejs-module-name}'
			'check-update': 'check-update'
			'install': 'install [package]'
			'uninstall': 'uninstall [nodejs-module-name]'
		  
		constructor: (moduleManager) ->
			super

			@addRoute 'package update', 'packages.manage.update', (origin, route) =>
				@reply origin, 'Checking for updates...'

				@checkUpdates()

				.then (modules) =>
					console.log modules
					@reply origin, "Modules [#{(m.name for m in modules)}] needs to be updated!"

					modules

				.then (modules) => @updateManyModules modules

				.done =>
					@reply origin, "Done updating modules."

				, (err) =>
					console.error err.stack
					@reply origin, "Uh oh, problem! #{err}"

			@addRoute 'package update :pkg', 'packages.manage.update', (origin, route) =>
				{pkg} = route.params

				@checkUpdates pkg

				.then ([module]) =>
					if module?
						@reply origin, "Module #{module.name} needs to be updated!"

						@updateManyModules [module]

					else @reply origin, "No need to update #{pkg}."

				.done =>
					@reply origin, "Done updating modules."

				, (err) =>
					console.error err.stack
					@reply origin, "Uh oh, problem! #{err}"

			@addRoute 'package check-update', 'packages.manage.check-update', (origin, route) =>
				@reply origin, 'Checking for updates...'

				@checkUpdates()

				.done (modules) =>
					console.log modules
					@reply origin, "Modules [#{(m.name for m in modules)}] needs to be updated!"

				, (err) =>
					console.error err.stack
					@reply origin, "Uh oh, problem! #{err}"

			@addRoute 'package install *', 'packages.manage.install', (origin, route) =>
				[pkg] = route.splats

				@reply origin, "Installing '#{pkg}'..."

				@npmInstall [pkg]

				.then ([installed, pkgData, stdout]) =>
					[modData] = _.toArray(pkgData)
					{name: pkgName, spec: version} = npa modData.what

					@moduleManager.loadModule pkgName
					[pkgName, version]
				
				.done ([pkgName, version]) =>
					console.log "Installed #{pkgName}, v#{version}"
					@reply origin, "Successfully installed '#{pkgName}' v#{version}!"

				, (err) =>
					console.error err.stack
					@reply origin, "Uh oh, error installing '#{pkg}'! #{err}"

			@addRoute 'package uninstall *', 'packages.manage.uninstall', (origin, route) =>
				[pkg] = route.splats

				@reply origin, "Uninstalling '#{pkg}'..."

				Q.ninvoke @moduleManager, 'unloadModule', pkg

				.then => @npmUninstall [pkg]

				.done =>
					@reply origin, "Successfully uninstalled '#{pkg}'!"

				, (err) =>
					console.error err.stack
					@reply origin, "Uh oh, error uninstalling '#{pkg}'! #{err}"

			npm.load { depth: Infinity }, (err, npm) =>
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
		npmUninstall: (args...) -> Q.ninvoke npm.commands, 'uninstall', args...
		npmRegistryGet: (args...) -> Q.ninvoke npm.registry, 'get', args...

		###
		Utility functions
		###
		findNodeModule: (nodeModules...) ->
			path.resolve __dirname, '../../..', (nodeModules.map (nm) -> "node_modules/#{nm}")...

		findPackageJson: (nodeModules...) ->
			path.resolve (@findNodeModule nodeModules...), 'package.json'

		packageJson: (nodeModules...) ->
			JSON.parse fs.readFileSync (@findPackageJson nodeModules...), encoding: 'utf-8'

		readPackageJson: (nodeModules...) ->
			packageJson = @packageJson nodeModules...

			packageJson._realPath = @findNodeModule nodeModules...
			packageJson._dependencies = deps = {}
			for dep,spec of packageJson.dependencies
				deps[dep] = @readPackageJson nodeModules..., dep

			packageJson

		getKureaModules: (pkg) ->
			modules =
				_.filter (_.keys @moduleManager.modules),
					(s) -> not _.startsWith s, '__'

			packageJsonFiles = {}

			for m in modules when (not pkg? or m is pkg)
				packageJsonFiles[m] = @readPackageJson m

			Q (@transformModuleObject modData for name,modData of packageJsonFiles)

		transformModuleObject: (modData) ->
			name: modData.name
			from: modData._from
			resolved: modData._resolved
			version: modData.version

			source: @determineUpdateSource modData._from, modData._resolved
			installWhere: path.resolve modData._realPath, '..', '..'
			dependencies: (@transformModuleObject dep for name, dep of modData._dependencies)

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
		checkUpdates: (pkg) =>
			Q.fcall ->
				throw new Error 'npm not yet loaded' if not npm.config.loaded

				console.log 'Npm is loaded'

			.then => @getKureaModules pkg

			.then (modules) => @checkUpdateRecursive modules

		checkUpdateRecursive: (modules) ->
			Q.all (@checkUpdateSingle m for m in modules)

			.then (needsUpdate) =>
				Q.all(
					for m,i in modules
						if needsUpdate[i] then m
						else @checkUpdateRecursive m.dependencies
				)

			.then (modules) -> _.flatten modules

		checkUpdateSingle: (module) ->
			console.log "** Checking #{module.name}; #{module.source.type}"

			switch module.source.type
				when 'git' then @checkUpdateGit module
				when 'npm' then @checkUpdateNpm module

				else no

		checkUpdateGit: (module) ->
			@gitLsRemote(module.source.repoUrl, ['HEAD'])

			.then (reply) ->
				[current, latest] = [module.source.commitHash, reply.HEAD.hash]

				console.log "#{module.source.repoUrl}: #{current[0...7]} vs #{latest[0...7]}"

				current isnt latest

		checkUpdateNpm: (module) ->
			@npmRegistryGet "https://registry.npmjs.com/#{module.source.name}", {}

			.then ([data]) => @npmFindLatestSatisfying module, data

			.then (latestVer) =>
				currentVer = module.version
				console.log "Is #{currentVer} less than #{latestVer}? #{semver.lt currentVer, latestVer}"

				semver.lt currentVer, latestVer

		npmFindLatestSatisfying: (module, regData) ->
			switch module.source.specType
				when 'version' then module.source.spec

				when 'range'
					semver.maxSatisfying (_.keys regData.versions), module.source.spec

				when 'tag'
					regData['dist-tags'][module.source.spec]

		###
		Updating
		###
		updateManyModules: (modules) ->
			Q.all(@updateModule m for m in modules)

		updateModule: (module) ->
			Q.fcall => Q.ninvoke @moduleManager, 'unloadModule', module.name

			.then => @npmInstall(module.installWhere, [module.from])

			.then => @moduleManager.loadModule(module.name, @moduleManager)
	
	PackageManagerModule