module.exports = (Module) ->
	Q = require 'q'
	colors = require 'irc-colors'
	_ = require 'underscore'
	_.str = require 'underscore.string'
	
	class PermissionsModule extends Module
		shortName: "Permissions"
		helpText:
			default: "A module for manually adding and removing permissions. Commands available: add, add-group, info, check"
			'permissions add': "Add a permission to the specified target, be it a user, a group or a combination!"
			'permissions add-group': "Add the target username to a group!"
			'permissions info': "Lists the groups you are in."
			'permissions check': "Checks if you or the target have the given permission."

		usage:
			'permissions add': "permissions add [target] [permission]"
			'permissions add-group': "permissions add-group [target] [group]"
			'permissions info': "permissions info"
			'permissions check': "permissions check [permission] {target}"
	
		constructor: (moduleManager) ->
			super(moduleManager)
	
			@permMan = @getBotManager().permissionManager
	
			@addRoute "permissions add :target :permission", "core.permission.modify.single", (origin, route) =>
				[target, permission] = [route.params.target.toLowerCase(), route.params.permission]
	
				@permMan.addPermission target, permission, (err) =>
					if err?
						@reply origin, "Uh oh, problem while adding permission! #{err}"
						console.error err.stack
	
					else
						@reply origin, "Added permission '#{permission}' to #{target}!"

			@addRoute "permissions add-group :target :group", "core.permission.modify.group", (origin, route) =>
				[target, group] = [route.params.target.toLowerCase(), route.params.group]
	
				@permMan.addGroup origin.bot, target, group, (err) =>
					if err?
						@reply origin, "Uh oh, problem while adding group! #{err}"
						console.error err.stack
	
					else
						@reply origin, "Added #{target} to group '#{group}'!"

			@addRoute "permissions info", (origin, route) =>
				{bot, user} = origin

				bot.userManager.getUsername origin, (err, username) =>
					@permMan.getGroups bot, username, (err, groups) =>
						if groups.length > 0
							@reply origin, "Your groups are #{_.str.toSentence (colors.bold(group) for group in groups)}."
							
						else @reply origin, "You are not in any group."
	
			checkPermission = (origin, route) =>
				permission = route.params.permission
				user = route.params.user ? origin.user
	
				@hasPermission { bot: origin.bot, channel: origin.channel, user: user }, permission, (err, matched) =>
					if err?
						@reply origin, "Uh oh, error! #{err}"
						return
	
					@reply origin, "Does #{user} match the permission? #{if matched then "Yes!" else "No!"}"
	
			@addRoute "permissions check :permission :user", checkPermission
			@addRoute "permissions check :permission", checkPermission
	
			@addRoute "dumpPerm", (origin, route) => @permMan.dump()
	
	
	PermissionsModule