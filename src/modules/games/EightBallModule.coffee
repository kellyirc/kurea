Module = require('../../core/Module').Module
color = require 'irc-colors'

class EightBallModule extends Module
	responses: [
		"Yes"
		"No"
		"Don't count on it"
		"Not counting on it"
		"Might just be so"
		"Yeah, sure"
		"What I know of, it might just be true"
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
		"Fuck off, I'm not going to answer right now"
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
		"Myth Confirmed"
		"Myth Busted"
		"Lookin' good, alright"
		"Yeah no, outlook NOT good"
		"You wish"
		"Ask me tomorrow"
		"Fosho!"
		"Lolno!"
		"tl;dr"
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
	shortName: "8Ball"
	helpText:
		default: "Ask the magical witty sentient 8-ball any yes-or-no question you desire! USAGE: !8ball"

	constructor: ->
		super()

		@addRoute "8ball :left", (origin, route) =>
			[bot, user, channel, left] = [origin.bot, origin.user, origin.channel, route.params.left]
			
			
			choice = Math.floor(Math.random() * @responses.length)
			@reply origin, @responses[choice]

exports.EightBallModule = EightBallModule