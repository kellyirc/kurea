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

		apiKey = @getApiKey 'github'

		@defaultGitHubParams =
			hostname: "api.github.com"
			headers: 
				"User-Agent": "kellyirc_kurea"

		[@owner, @repo, @head] = ["kellyirc", "kurea", "master"]

		@addRoute "git-check", (origin, route) =>
			@checkUpdate(apiKey)

	getCurrentCommit: (callback) =>
		# if @lastCommit?
		# 	callback null, @lastCommit
		# 	return

		Q.nfcall fs.readFile, ".git/HEAD",
			encoding: "utf-8"

		.then (filedata) =>
			[match, headPath] = /ref: (.+)\n/.exec(filedata)

			Q.nfcall fs.readFile, ".git/#{headPath}",
				encoding: "utf-8"

		.then (filedata) =>
			hash = filedata.trim()
			@lastCommit = hash
			callback null, hash

		.fail (err) =>
			callback err, null

	checkUpdate: (apiKey) ->
		@getCurrentCommit (err, hash) =>
			if err?
				console.error "There was a problem!"
				console.error err.stack

			compareOptions =
				auth: "#{apiKey}:x-oauth-basic"
				path: "/repos/#{@owner}/#{@repo}/compare/#{hash}...#{@head}"

			console.log "Creating request..."

			req = https.request _.extend(compareOptions, @defaultGitHubParams), (res) =>
				console.log "statusCode: #{res.statusCode}; #{res.headers['x-ratelimit-remaining']} of #{res.headers['x-ratelimit-limit']} requests left."

				chunks = []
				res.on 'data', (data) =>
					chunks.push data
					
				.on 'end', =>
					data = JSON.parse Buffer.concat(chunks).toString()

					if data.commits.length > 0
						console.log "Update available!"
						@update data
					else
						console.log "No need to update..."

			req.on 'error', (e) -> console.error e.stack
			req.end()

	update: (data) ->
		[meh..., last] = data.commits
		headHash = last.sha
		console.log "Updating to #{headHash}"

		modulesOnly = _.all (file.filename for file in data.files), (v) => _.str.startsWith(v, "src/modules/")

		# promises = []

		# for file in data.files
		# 	filename = path.resolve file.filename
		# 	console.log "File #{filename} is updated"

		# 	promises.push Q.fcall =>
		# 		deferred = Q.defer()

		# 		https.get "https://raw.github.com/#{@owner}/#{@repo}/#{headHash}/#{file.filename}", (res) =>
		# 			console.log "statusCode: #{res.statusCode};"

		# 			chunks = []
		# 			res.on 'data', (data) =>
		# 				chunks.push data
		# 			.on 'end', =>
		# 				contents = Buffer.concat(chunks).toString()

		# 				fs.writeFileSync filename, contents
		# 				deferred.resolve contents
		# 			.on 'error', (err) =>
		# 				deferred.reject err

		# 		deferred

		# Q.all(promises)

		Q.nfcall child_process.exec, "git pull"

		.then (stdout, stderr) =>
			console.log "Updated all files to #{headHash}"
			# @lastCommit = headHash

			if not modulesOnly
				console.log "Update contains files that are not modules; a restart is required"
				process.exit 0

		.fail (err) =>
			console.log "Error:", err

exports.GitUpdateModule = GitUpdateModule