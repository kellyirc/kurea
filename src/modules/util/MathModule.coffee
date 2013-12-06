Module = require('../../core/Module').Module
color = require 'irc-colors'
parser = require('mathjs')().parser()

class MathModule extends Module
	shortName: "Math"
	helpText:
		default: "Evaluates math expressions. USAGE:![math|calc] [expression]"

	constructor: ->
		super()

		@addRoute "math *", @execute
		@addRoute "calc *", @execute

	execute: (origin, route) =>
		# Since we can't type new lines, pipe characters will separate multiple expressions
		expr = route.splats[0].replace /\|/g, '\n'
		try
			result = parser.eval(expr)
			if result instanceof Object # For multiple results
				result = (value for key, value of result).join(", ")
			@reply origin, "#{origin.user}, your answer is #{color.bold(result)}"
		catch e
			@reply origin, "Unable to evaluate expression: #{e.message}"

exports.MathModule = MathModule