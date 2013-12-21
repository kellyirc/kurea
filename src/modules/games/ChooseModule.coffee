module.exports = (Module) ->
	color = require 'irc-colors'
	
	class ChooseModule extends Module
		shortName: "Choose"
		helpText:
			default: "Can't make a decision between two things? I sure can!"
		usage:
			default: "choose [this] or [that]"
	
		constructor: (moduleManager) ->
			super(moduleManager)
	
			@addRoute "choose :left or :right", (origin, route) =>
				[bot, user, channel, left, right] = [origin.bot, origin.user, origin.channel, route.params.left, route.params.right]
	
				choice = if Math.random() > 0.5 then left else right
				@reply origin, "#{user}, for your certain predicament, I choose #{color.bold(choice)}."
	
	
	ChooseModule