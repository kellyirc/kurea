module.exports = (Module) ->
	
	class EchoModule extends Module
		shortName: "Echo"
		helpText:
			default: "I'll say whatever you want me to say."
		usage:
			default: "echo [target] [message]"
	
		constructor: (moduleManager) ->
			super(moduleManager)
	
			@addRoute "echo :target *", "core.send.message", (origin, route) =>
				origin.bot.say route.params.target, route.splats[0]
	
	
	EchoModule