module.exports = (Module) ->
	
	class PermissionsModule extends Module
		shortName: "Permissions"
		helpText:
			default: "A module for manually adding and removing permissions. Commands available: add"
	
		constructor: (moduleManager) ->
			super(moduleManager)
	
			@permMan = @getBotManager().permissionManager
	
			@addRoute "permissions add :target :permission", (origin, route) =>
				[target, permission] = [route.params.target.toLowerCase(), route.params.permission]
	
				@permMan.addPermission target, permission, (err) =>
					if err? then @reply origin, "Uh oh, problem while adding permission! #{err}"
	
					else
						@reply origin, "Added permission '#{permission}' to #{target}!"

			@addRoute "permissions add-group :target :group", (origin, route) =>
				[target, group] = [route.params.target.toLowerCase(), route.params.group]
	
				@permMan.addGroup origin.bot, target, group, (err) =>
					if err? then @reply origin, "Uh oh, problem while adding group! #{err}"
	
					else
						@reply origin, "Added group '#{group}' to #{target}!"
	
			permtestanFunc = (origin, route) =>
				permission = route.params.permission
				user = route.params.user ? origin.user
	
				@hasPermission { bot: origin.bot, channel: origin.channel, user: user }, permission, (err, matched) =>
					if err?
						@reply origin, "Uh oh, error! #{err}"
						return
	
					@reply origin, "Does #{user} match the permission? #{if matched then "Yes!" else "No!"}"
	
			@addRoute "permtestan :user :permission", permtestanFunc
			@addRoute "permtestan :permission", permtestanFunc
	
			@addRoute "dumpPerm", (origin, route) => @permMan.dump()
	
	
	PermissionsModule