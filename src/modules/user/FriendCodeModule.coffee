module.exports = (Module) ->
	
	class FriendCodeModule extends Module
		shortName: "FriendCode"
		helpText:
			default: "Use friendcode *code* to register your friend code. Use friendcode *nick* to see a registered user's friend code."
		usage:
			default: "friendcode *"
		numberGroups: 3 #the amount of numbers separated by dashes
	
		constructor: (moduleManager) ->
			super(moduleManager)

			@getApi().getFriendCode = (origin, callback) =>
				@getUserData origin, "friendCode", (data) =>
					callback?(data)


			@registerApi()

			@addRoute "friendcode :value", (origin, route) =>

				friendCodeRegex = new RegExp("\\b([0-9]{4}-){#{@numberGroups - 1}}([0-9]{4}){1}\\b")		

				value = @reformatFriendCode(route.params.value)

				if value.match(friendCodeRegex)
					@setUserData origin, "friendCode", value, () =>
						@getUserData origin, "friendCode", (data) =>
							@reply origin, "Your friend code is now #{data}"
				else
					@userInformationManager.getData origin.bot.config.server, @shortName, value, "friendCode", (data) =>
						if data? then @reply origin, "#{value}'s friend code is #{data}" else @reply origin, "#{value}'s friend code is not stored!"

			@addRoute "friendcode", (origin, route) =>
				@reply origin, @helpText.default

		reformatFriendCode: (unformattedCode) ->
			StringSplice = (stringToSplice, index, charsToRemove, stringToInsert) ->
				return stringToSplice.slice(0, index) + stringToInsert + stringToSplice.slice(index + Math.abs(charsToRemove))


			friendCodeRegex = new RegExp("\\b([0-9]{4}){#{@numberGroups}}\\b")

			formattedCode = unformattedCode
			if unformattedCode.match(friendCodeRegex)
				dashesToInsert = @numberGroups - 1
				(formattedCode = StringSplice(formattedCode, (4 * (x + 1) + x), 0, "-")) for x in [0..(dashesToInsert-1)]
			return formattedCode

		
	FriendCodeModule