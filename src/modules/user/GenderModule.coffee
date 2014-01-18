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
				console.log "Getting gender for #{origin.user}"
				@getUserData origin, "gender", (data) =>
					@reply origin, "Your gender is #{data}"

			@addRoute "gender :gender", (origin, route) =>

				console.log route

				@setUserData origin, "gender", route.params.gender, () =>
					console.log "inside set callback"

					@getUserData origin, "gender", (data) =>
						console.log "inside get callback"
						@reply origin, "Your gender is now #{data}"
		
	GenderModule