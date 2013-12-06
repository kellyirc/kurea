Module = require('../../core/Module').Module
color = require 'irc-colors'
math = require('mathjs')()
class MathModule extends Module
	shortName: "Math"
	helpText:
		default: "Evaluates math expressions. USAGE:![math|calc] [expression]"

	constructor: ->
		super()

		@addRoute "math *", @execute
		@addRoute "calc *", @execute

	execute: (origin, route) =>
		expr = route.splats[0]
		try
			result = math.eval(expr)
			@reply origin, "#{origin.user}, your answer is #{result}"
		catch e
			@reply origin, "Unable to evaluate expression: #{e.message}"

exports.MathModule = MathModule