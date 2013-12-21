module.exports = (Module) ->
	
	class SeenModule extends Module
		shortName: "Seen"
		helpText:
			default: "Find when I last saw someone."
		usage:
			default: "seen [nick]"
	
		constructor: (moduleManager) ->
			super(moduleManager)
			@db = @newDatabase "last-seen"
	
			@on 'message#', (bot, nick, to, text, msg) =>
				query =
					nick: nick
				update =
					nick: nick
					time: new Date()
					msg: text
					chan: to
				opt =
					upsert: true
				@db.update query, update, opt, (err) ->
					console.error err if err?
	
			@addRoute "seen :nick", (origin, route) =>
	
				[bot, nick] = [origin.bot, route.params.nick]
				@db.find {nick: nick}, (err, docs) =>
					console.error err if err?
					if docs.length is 0
						@reply origin, "I've never seen #{nick} before."
					else
						d = docs[0]
						@reply origin, "I last saw #{d.nick} on #{d.time} saying \"#{d.msg}\" in #{d.chan}"
	
				
	
	
	SeenModule