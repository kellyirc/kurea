Module = require('../../core/Module').Module

class PingModule extends Module
	shortName: "Ping"
	helpText:
	  default: "Ping all users in the channel. Don't annoy them too much, now!"
	  
	constructor: (moduleManager) ->
		super(moduleManager)
    
		@addRoute "ping", (origin, route) =>
			[bot, channel] = [origin.bot, origin.channel]
      
			@reply origin, "Ping! #{bot.getUsers(channel).join(", ")}"
      
exports.PingModule = PingModule