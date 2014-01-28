module.exports = (Module) ->
	path = require 'path'

	class CardplayModule extends Module
		shortName: 'Cardplay'

		constructor: (moduleManager) ->
			super(moduleManager)

			CardManager = require './card-manager'
			CardManager.load path.resolve __dirname, './cards'

	CardplayModule