module.exports = (Module) ->
	request = require 'request'
	cheerio = require 'cheerio'
	
	class LinkParseModule extends Module
		shortName: "LinkParse"
		helpText:
			default: "I parse your links so people know what they are!"
	
		constructor: (moduleManager) ->
			super(moduleManager)
	
			urlRegex = /(https?:\/\/[^\s]+)/g
			@on 'message', (bot, sender, channel, message) =>
				@moduleManager.canModuleRoute @, bot.getServer(), channel, false, =>
					links = message.match urlRegex
					console.log links
					links?.forEach (link) =>
						request link, (e,r,body) =>
							console.log 'inner'
							$ = cheerio.load body
							title = $('title').html()
							console.log title
							bot.say channel, "#{sender}'s URL » #{title}" if title?
	
	
	LinkParseModule
