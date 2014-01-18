module.exports = (Module) ->
	
	class GenderModule extends Module
		shortName: "Gender"
		helpText:
			default: "Change the gender I recognize you as!"
		usage:
			default: "gender [male|female|*]"
	
		constructor: (moduleManager) ->
			super(moduleManager)

			@getApi().isMale = (origin, callback) =>
				@getUserData origin, "gender", (data) =>
					callback /\bmale/.test(data.toLowerCase())

			@getApi().isFemale = (origin, callback) =>
				@getUserData origin, "gender", (data) =>
					callback /\bfemale/.test(data.toLowerCase())

			@registerApi()

			@addRoute "gender", (origin, route) =>
				@getUserData origin, "gender", (data) =>
					@reply origin, "Your gender is #{data}"

			@addRoute "gender :gender", (origin, route) =>

				@setUserData origin, "gender", route.params.gender, () =>

					@getUserData origin, "gender", (data) =>
						@reply origin, "Your gender is now #{data}."
		
	GenderModule