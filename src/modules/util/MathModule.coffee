Module = require('../../core/Module').Module
color = require 'irc-colors'
parser = require('mathjs')().parser()

class MathModule extends Module
	shortName: "Math"
	helpText:
		default: "Evaluates math expressions. USAGE:![math|calc] [expression]"

	constructor: (moduleManager) ->
		super(moduleManager)

		@addRoute "math *", @execute
		@addRoute "calc *", @execute

	execute: (origin, route) =>
		expr = route.splats[0]
		try
			result = parser.eval(expr)
			@reply origin, "#{origin.user}, your answer is #{color.bold(result)}"
		catch e
			@reply origin, "Unable to evaluate expression: #{e.message}"

exports.MathModule = MathModule