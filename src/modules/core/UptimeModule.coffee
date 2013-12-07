Module = require('../../core/Module').Module

class UptimeModule extends Module
	shortName: "Uptime"
	helpText:
	  default: "See how long I've been going ;)"
	  
  constructor: ->
    super()
    
    @addRoute "uptime", (origin, route) =>
      [bot, channel] = [origin.bot, origin.channel]
	  
	  diff = new Date() - @dateStarted
      
      @reply origin, "Current uptime is #{diff}"
      
exports.UptimeModule = UptimeModule