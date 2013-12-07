Module = require('../../core/Module').Module

class FuckModule extends Module
	shortName: "Fuck"
	helpText:
	  default: "Fuck off"
	  
  constructor: ->
    super()
    
    @addRoute "fuck", (origin, route) =>
      [bot, channel] = [origin.bot, origin.channel]
      
      @reply origin, "FUCK YOU JETLAG"
      
exports.FuckModule = FuckModule