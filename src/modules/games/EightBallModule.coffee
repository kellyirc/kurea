module.exports = (Module) ->
	color = require 'irc-colors'
	
	class EightBallModule extends Module
		shortName: "8Ball"
		helpText:
			default: "Ask the magical witty sentient 8-ball any yes-or-no question you desire!"
		usage:
			default: "8ball {question}"
		responses: [
			"Yes"
			"No"
			"Don't count on it"
			"Not counting on it"
			"Might just be so"
			"Yeah, sure"
			"With what I know, it might just be true"
			"As I see it, yes"
			"As I see it, no"
			"I don't think so"
			"I think so"
			"Yeah"
			"Nah"
			"Yea"
			"Nay"
			"The majority of my sources say \"YES\""
			"The majority of my sources say \"NO\""
			"Weakling question, NEXT!"
			"My answer is... YES"
			"My Answer is... NO"
			"Why should I bother answering?"
			"You go figure it out"
			"Can't be arsed to answer"
			"Ask again later"
			"Likely"
			"Not likely"
			"Nuh-uh"
			"Uh-huh"
			"Something along those lines"
			"No way in hell"
			"Doubtful, really"
			"Without a doubt"
			"Naw"
			"Yup"
			"Yeeeeeuuuuuup"
			"Nonono"
			"Stop bothering me, I'm busy!"
			"Think about it"
			"When pigs fly"
			"Myth confirmed"
			"Myth busted"
			"Lookin' good, alright"
			"Yeah no, outlook NOT good"
			"You wish"
			"Ask me tomorrow"
			"Fosho!"
			"Lolno!"
			"tl;dr no"
			"Mmmyeah"
			"Mmmno"
			"Surely"
			"Ain't no way that'd be true"
			"Obviously yes"
			"Obviously no"
			"Think about your question, then try again"
			"Consult your beloved"
			"Ask someone else"
			"Only time will tell..."
			"What do you think?"
		]
	
		constructor: (moduleManager) ->
			super(moduleManager)
	
			@addRoute "8ball *", (origin, route) =>
				choice = Math.floor(Math.random() * @responses.length)
				@reply origin, @responses[choice]
	
	
	EightBallModule
