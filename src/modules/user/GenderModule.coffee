module.exports = (Module) ->
	
	class GenderModule extends Module
		shortName: "Gender"
		helpText:
			default: "Change the gender I recognize you as!"
		usage:
			default: "gender [male|female|*]"
	
		constructor: (moduleManager) ->
			super(moduleManager)

			@addRoute "gender", (origin, route) =>
				@getUserData origin, "gender", (data) =>
					console.log data

			@addRoute "gender :gender", (origin, route) =>

				console.log route

				@setUserData origin, "gender", route.params.gender, () =>
					console.log "inside set callback"

					@getUserData origin, "gender", (data) =>
						console.log "inside get callback"
						console.log data
		
	GenderModule