module.exports = (Module) ->
	
	class NickModule extends Module
		shortName: "Nick"
		helpText:
			default: "Change my nick."
		usage:
			default: "nick [new nick]"
	
		constructor: (moduleManager) ->
			super(moduleManager)
	
			@addRoute "nick :nick", "core.manage.change.nick", (origin, route) =>
				origin.bot.changeNick route.params.nick, (err, oldnick, newnick, channels, msg) =>
					if err?
						console.error err.stack
						@reply origin, "I can't call myself that! (#{err.command})"
					else
						@reply origin, "Call me #{newnick}"
	
	
	NickModule