Module = require('../../core/Module').Module

class MemoModule extends Module
	shortName: "Memo"
	helpText:
		default: "I'll save messages for people who aren't here now. For multiple nicks, separate by semicolons. For aliases, separate by commas."
	usage:
		default: "memo [nick(s)]"

	constructor: (moduleManager) ->
		super(moduleManager)
		@db = @newDatabase 'memos'

		@on 'names', (bot, channel, nicks) =>
			# Bot is joining channel
			for nick of nicks
				do (nick) =>
					@checkMemos(bot, nick)

		@on 'join', (bot, chan, nick, msg) =>
			@checkMemos(bot, nick)

		@on 'nick', (bot, oldnick, newnick, channels, msg) =>
			@checkMemos(bot, newnick)

		@addRoute 'memo :nicks :message', (origin, route) =>
			nicks = route.params.nicks
			for nick in nicks.split ';'
				do (nick) =>
					aliases = nick.toLowerCase().split ','
					for alias in aliases
						if @nickIsOnline origin.bot, alias
							@reply origin, "Silly, #{alias} is online. Tell him/her yourself!"
							return
					@db.insert
						server: origin.bot.getServer()
						from: origin.user
						time: new Date()
						to: aliases
						msg: route.params.message,
						(err) =>
							if err?
								console.error err
							else
								@reply origin, "Alright, I'll let #{nick} know."

	checkMemos: (bot, nick) ->
		@db.find {server: bot.getServer(), to: nick.toLowerCase()}, (err, docs) =>
			try
				console.error err if err?
				for doc in docs
					bot.say nick, "Hey #{nick}! #{doc.from} wanted me to tell you, \"#{doc.msg}\" on #{doc.time}"
					@db.remove {_id: doc._id}, {}
			catch e
				console.error "Unable to check memos."
				console.error e.stack

	nickIsOnline: (bot, nick) ->
		nick = nick.toLowerCase()
		for chan in bot.getChannels()
			for user in bot.getUsers(chan)
				if user.toLowerCase() is nick
					return true
		return false
			

exports.MemoModule = MemoModule