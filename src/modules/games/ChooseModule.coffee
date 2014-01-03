module.exports = (Module) ->
	color = require 'irc-colors'
	
	class ChooseModule extends Module
		shortName: "Choose"
		helpText:
			default: "Can't make a decision between two things? I sure can! Maybe even three, or more!"
		usage:
			default: "choose [this] or {that} or {that} or ..."
	
		constructor: (moduleManager) ->
			super(moduleManager)
	
			@addRoute "choose :choices", (origin, route) =>
				[bot, user, channel, choices] = [origin.bot, origin.user, origin.channel, route.params.choices]
				console.log choices
				choices = choices.split /\bor\b/
				console.log choices
				choice = choices[~~(Math.random()*choices.length)].trim()
				@reply origin, "#{user}, for your certain predicament, I choose #{color.bold(choice)}."
	
	
	ChooseModule