module.exports = (Module) ->
	
	class JoinModule extends Module
		shortName: "Join"
		helpText:
			default: "Joins a channel. Delimit channels by spaces or commas."
		usage:
			default: "join [channel1] {channel2} {channel3}..."
		constructor: (moduleManager) ->
			super(moduleManager)
	
			@addRoute "join *", (origin, route) =>
				[bot, user, channel, chans] = [origin.bot, origin.user, origin.channel, route.splats[0].split(/[\s,]+/)]
				serverName = bot.conn.opt.server
	
				# TODO: error checking and spliting for multiple joins
				for chan in chans
					bot.join chan, =>
						@reply origin, "I have joined #{chan}."
						# Explicitly disable all modules in a new channel
						moduleManager._getModuleActiveData {server: serverName, channel: chan}, (data) =>
							if data.length is 0
								moduleManager.disableAllModules serverName, chan

	
	
	JoinModule