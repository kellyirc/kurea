module.exports = (Module) ->
	
	class PingModule extends Module
		shortName: "Ping"
		helpText:
			default: "Ping all users in the channel. Don't annoy them too much, now!"
		usage:
			default: "ping"
		  
		constructor: (moduleManager) ->
			super(moduleManager)
	    
			@addRoute "ping", (origin, route) =>
				[bot, channel] = [origin.bot, origin.channel]
	      
				@reply origin, "Ping! #{bot.getUsers(channel).join(", ")}"
	      
	
	PingModule