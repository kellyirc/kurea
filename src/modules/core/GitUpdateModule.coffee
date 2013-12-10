Module = require('../../core/Module').Module
Q = require 'q'
fs = require 'fs'
https = require 'https'
_ = require 'underscore'
path = require 'path'
child_process = require 'child_process'

class GitUpdateModule extends Module
	shortName: "GitUpdate"

	constructor: (moduleManager) ->
		super(moduleManager)

		accessToken = @getApiKey 'github'

		if not accessToken?
			console.log "No access token specified in config files; I will now stop functioning completely because yeah."
			return

		@defaultGitHubParams =
			hostname: "api.github.com"
			headers:
				"User-Agent": "kellyirc_kurea"

		[@owner, @repo, @head] = ["kellyirc", "kurea", "master"]

		@autoUpdateId = setInterval =>
			@checkUpdate accessToken
		, 10 * 60 * 1000

		@addRoute "update", (origin, route) =>
			@checkUpdate accessToken, origin

		@addRoute "auto-update :min", (origin, route) =>
			timeMin = route.params.min

			if timeMin is "never"
				clearInterval @autoUpdateId if @autoUpdateId?
				@autoUpdateId = null

				@reply origin, "Disabled auto-update checking. (CANNOT BE RE-ENABLED AT THIS TIME)"

	destroy: =>
		console.log "Killing old update interval"
		clearInterval @autoUpdateId if @autoUpdateId?

		super()

	getCurrentCommit: (callback) =>
		Q.nfcall fs.readFile, ".git/HEAD",
			encoding: "utf-8"

		.then (filedata) =>
			[match, headPath] = /ref: (.+)\n/.exec(filedata)

			Q.nfcall fs.readFile, ".git/#{headPath}",
				encoding: "utf-8"

		.then (filedata) =>
			hash = _.str.trim( filedata )
			@lastCommit = hash
			callback null, hash

		.fail (err) =>
			callback err, null

	checkUpdate: (accessToken, origin) ->
		@getCurrentCommit (err, hash) =>
			if err?
				console.error "There was a problem!"
				console.error err.stack
				return

			compareOptions =
				auth: "#{accessToken}:x-oauth-basic"
				path: "/repos/#{@owner}/#{@repo}/compare/#{hash}...#{@head}"

			console.log "Checking for update..."
			@reply origin, "Checking for updates..." if origin?

			req = https.request _.extend(compareOptions, @defaultGitHubParams), (res) =>
				chunks = []
				res.on 'data', (data) =>
					chunks.push data
					
				.on 'end', =>
					data = JSON.parse Buffer.concat(chunks).toString()

					if data.commits.length > 0
						console.log "Update available!"
						@update data, origin
					else
						console.log "No need to update..."
						@reply origin, "No new commits available; no update is performed." if origin?

			req.on 'error', (e) -> console.error e.stack
			req.end()

	update: (data, origin) ->
		[meh..., last] = data.commits
		headHash = last.sha
		console.log "Updating to #{headHash}"

		filenames = (file.filename for file in data.files)
		modulesOnly = _.all filenames, (v) => _.str.startsWith(v, "src/modules/")

		Q.fcall =>
			console.log "Running 'git pull'..."
			@reply origin, "Pulling new commits..." if origin?

			deferred = Q.defer()

			gitPull = child_process.exec "git pull", (err, stdout, stderr) ->
				if err? then deferred.reject err

			gitPull.stdout.on 'data', (chunk) -> console.log "#{chunk}"
			gitPull.stderr.on 'data', (chunk) -> console.error "#{chunk}"
			gitPull.on 'close', (code, signal) -> deferred.resolve code, signal

			deferred.promise

		.then =>
			if "package.json" in filenames
				console.log "'npm install'ing potential new deps"

				deferred = Q.defer()
				gitPull = child_process.exec "npm install", (err, stdout, stderr) ->
					if err? then deferred.reject err

				gitPull.stdout.on 'data', (chunk) -> console.log "#{chunk}"
				gitPull.stderr.on 'data', (chunk) -> console.error "#{chunk}"
				gitPull.on 'close', (code, signal) -> deferred.resolve code, signal

				deferred.promise

		.then =>
			console.log "Updated all files to #{headHash}"
			@reply origin, "Updated all files to latest commit." if origin?
			# @lastCommit = headHash

			# console.log "modulesOnly = #{modulesOnly}"
			if not modulesOnly
				console.log "Update contains files that are not modules; exiting"
				@reply origin, "Because some of the updated files are not module files, I will restart." if origin?
				process.exit 0

		.fail (err) =>
			console.log "Error:", err

exports.GitUpdateModule = GitUpdateModule