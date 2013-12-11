Module = require('../../core/Module').Module
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
			links = message.match urlRegex
			links?.forEach (link) =>
				request link, (e,r,body) =>
					$ = cheerio.load body
					title = $('title').text()
					bot.say channel, "#{sender}'s URL » #{title}" if title isnt '' or undefined

exports.LinkParseModule = LinkParseModule