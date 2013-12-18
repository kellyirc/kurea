Module = require('../../core/Module').Module

class UptimeModule extends Module
	shortName: "Uptime"
	helpText:
		default: "See how long I've been going ;)"
	usage:
		default: "uptime"
	  
	constructor: (moduleManager) ->
		super(moduleManager)
    
		@addRoute "uptime", (origin, route) =>
			[bot, channel] = [origin.bot, origin.channel]
		
			t = new Date() - bot.dateStarted
			s = ((t / 1000) % 60).toFixed()
			m = ((t / (1000*60)) % 60).toFixed()
			h = ((t / (1000*60*60)) % 24).toFixed()
			@reply origin, "Current uptime is #{h} hours, #{m} minutes, #{s} seconds"
      
exports.UptimeModule = UptimeModule