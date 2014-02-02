
spawn = require('child_process').spawn

module.exports = (Module) ->
	
	class ShellModule extends Module
		shortName: "Shell"
		helpText:
			default: "Run a shell command. This can be pretty dangerous, so please know what you're doing first!"
		usage:
			default: "shell <cmd>"
		  
		constructor: (moduleManager) ->
			super(moduleManager)
	    
			@addRoute "shell *", "shell.superdangerous.danger.thiscanbereallydangerous", (origin, route) =>
				_cmd = route.splats[0].split ' '

				[cmd, args] = [(_cmd.slice 0,1)[0], ((_cmd.slice 1) ? []) ]
				@runCommand cmd, args,
					(message) => @reply origin, message,
					(error) => @reply origin, "Hey, that command is causing problems, please don't do it again!",
					() =>

		runCommand: (command, args, callback, errorCallback, endCallback) ->
			child = spawn command, args
			child.stdout.on 'data', (buffer) -> callback buffer.toString()
			child.stdout.on 'end', endCallback
			child.on 'error', errorCallback
	
	ShellModule