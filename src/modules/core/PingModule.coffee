Module = require('../../core/Module').Module

class PingModule extends Module
	shortName: "Ping"
	helpText:
	  default: "Ping all users in the channel. Don't annoy them too much, now!"
	  
  constructor: ->
    super()
    
    @addRoute "ping", (origin, route) =>
      [bot, chan] = [origin.bot, origin.chan]
      
      names = bot.getUsers(chan)
      @reply origin, "Ping! #{s}" for s in names
      
exports.PingModule = PingModule
