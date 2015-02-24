module.exports = (Module) ->

	crypto = require "crypto"
	_ = require "lodash"

	class HashModule extends Module
		shortName: "Hash"
		helpText:
			default: "Hash a string to one of many hashes"
			"hash-list": "Get a list of all possible hashes!"
		usage:
			default: "hash [crypto] [hash]"
			"hash-list": "hash-list"

		constructor: (moduleManager) ->
			super moduleManager

			@algorithms = crypto.getHashes().map (algorithm) -> algorithm.toLowerCase()

			@addRoute "hash-list", (origin) =>
				@reply origin, "Available hash functions: #{@algorithms.join ', '}"

			@addRoute "hash :algo :text", (origin, route) =>
				[algo, text] = [route.params.algo, route.params.text]

				if !_.contains @algorithms, algo
					@reply origin, "No such hash function exists."
					retunr

				hashed = crypto.createHash algo
					.update text, "utf-8"
					.digest "hex"

				@reply origin, "#{algo}(#{text}) = #{hashed}"

	HashModule