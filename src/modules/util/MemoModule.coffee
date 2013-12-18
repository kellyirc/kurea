Module = require('../../core/Module').Module

class MemoModule extends Module
	shortName: "Memo"
	helpText:
		default: "I'll save messages for people who aren't here now. For multiple nicks, separate by semicolons. For aliases, separate by commas. See also: memo-list, memo-cancel"
		"memo-list": "Lists all pending memos you have sent. They are given number labels, to be used with memo-cancel."
		"memo-cancel": "Cancels a memo that hasn't been sent yet. Specify the memo number or 'last' for the last memo you sent."
	usage:
		default: "memo [nick(s)]"
		"memo-list": "memo-list"
		"memo-cancel": "memo-cancel [memo #|last]"

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

		@addRoute 'memo :nicks *', (origin, route) =>
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
						msg: route.splats[0],
						(err) =>
							if err?
								console.error err
							else
								@reply origin, "Alright, I'll let #{nick} know."

		@addRoute 'memo-list', (origin, route) =>
			@db.find
				server: origin.bot.getServer()
				from: origin.user,
				(err, docs) =>
					try
						console.log "listing memos"
						console.error err if err?
						docs = @db.sort docs, time: 1
						if docs.length is 0
							@reply origin, "You have no pending memos."
						else
							for doc, index in docs
								@reply origin, "#{index+1}: To #{doc.to}, '#{doc.msg}' on #{doc.time}"
					catch e
						console.log "Unable to list memos."
						console.log e.stack

		@addRoute 'memo-cancel :index(\\d+|last)', (origin, route) =>
			index = route.params.index
			@db.find
				server: origin.bot.getServer()
				from: origin.user,
				(err, docs) =>
					try
						console.log "found some"
						console.error err if err?
						docs = @db.sort docs, time: 1
						index = if index is "last" then docs.length-1 else +index - 1
						if docs.length is 0
							@reply origin, "You have no memos to cancel."
						else if index < 0 or index >= docs.length
							@reply origin, "Out of bounds memo index. You have #{docs.length} memos."
						else
							doc = docs[index]
							@db.remove {_id: doc._id}, {}, (err, numRemoved) =>
								try
									if err?
										console.log err
										@reply origin, "Unable to cancel memo."
									if numRemoved is 1
										@reply origin, "Canceled memo to #{doc.to}, '#{doc.msg}' on #{doc.time}."
									else
										@reply origin, "I dunno, apparently that memo doesn't exist??"
								catch e
									console.log "Error cancelling memos."
									console.log e.stack
								
								
					catch e
						console.log "Unable to list memos."
						console.log e.stack
					


	checkMemos: (bot, nick) ->
		@db.find {server: bot.getServer(), to: nick.toLowerCase()}, (err, docs) =>
			try
				console.error err if err?
				for doc in docs
					bot.say nick, "Hey #{nick}! #{doc.from} wanted me to tell you, '#{doc.msg}' on #{doc.time}"
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