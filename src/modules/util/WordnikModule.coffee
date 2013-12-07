Module = require('../../core/Module').Module
color = require 'irc-colors'
Swagger = require "swagger-client"

partsOfSpeech = [
	"noun"
	"adjective"
	"verb"
	"adverb"
	"interjection"
	"pronoun"
	"preposition"
	"abbreviation"
	"affix"
	"article"
	"auxiliary-verb"
	"conjunction"
	"definite-article"
	"family-name"
	"given-name"
	"idiom"
	"imperative"
	"noun-plural"
	"noun-posessive"
	"past-participle"
	"phrasal-prefix"
	"proper-noun"
	"proper-noun-plural"
	"proper-noun-posessive"
	"suffix"
	"verb-intransitive"
	"verb-transitive"
]

class WordnikModule extends Module
	shortName: "Wordnik"
	helpText:
		default: "Accesses Wordnik API for dictionary functions. Current commands: define, example, rhyme, synonym, antonym, wordoftheday"
		define: "Gets the definition for words. (case-sensitive) Usage: !define [word]"
		example: "Gets an example sentence using the given word. (case-sensitive) Usage: !example [word]"
		rhyme: "Gets the first 30 words that rhyme with the given word. Usage: !rhyme [word]"
		synonym: "Gets synonyms for the given word. Usage: !synonym [word]"
		antonym: "Gets antonyms for the given word. Usage: !antonym [word]"
		wordoftheday: "Gets the word of the day. Usage: !wordoftheday"
		randomwords: "Gets some random words. Usage !randomwords {part of speech}. Available parts of speech: noun, adjective, verb, adverb, interjection, pronoun, preposition, abbreviation, affix, article, auxiliary-verb, conjunction, definite-article, family-name, given-name, idiom, imperative, noun-plural, noun-posessive, past-participle, phrasal-prefix, proper-noun, proper-noun-plural, proper-noun-posessive, suffix, verb-intransitive, verb-transitive"

	constructor: ->
		super()
		Swagger.authorizations.add("key", new Swagger.ApiKeyAuthorization("api_key", "35357a15cc56445a9600f093f24011f7d4e7094b1b0eaf1d5", "header"))
		@swagger = new Swagger.SwaggerApi {
			url: "https://api.wordnik.com/v4/resources.json"
			success: -> console.log "SWAGGER IS READY"
		}
		@addRoute "define :word", (origin, route) =>
			if not @swagger.ready
				@reply origin, "Sorry, the Wordnik API isn't ready yet."
				return

			@swagger.apis.word.getDefinitions
				word: route.params.word
				limit: 1,
				(data) =>
					try
						response = JSON.parse(data.content.data.toString()) # wow gross
						if response.length is 0
							@reply origin, "No definitions found."
							return

						def = response[0].text.split('   ')
						if def.length >= 2
							def = "#{color.green(def[0])}  #{color.olive(def[1..].join('   '))}"
						else
							def = color.olive(def[0])

						@reply origin, def
					catch e
						console.log e.message
						@reply origin, "Unable to find definiton."
				(err) =>
					@reply origin, "No definitions found."

		@addRoute "example :word", (origin, route) =>
			if not @swagger.ready
				@reply origin, "Sorry, the Wordnik API isn't ready yet."
				return

			@swagger.apis.word.getTopExample
				word: route.params.word
				(data) =>
					try
						response = JSON.parse(data.content.data.toString()) # wow gross
						if not response.text?
							@reply origin, "No example found."
							return
						example = color.green response.text
						@reply origin, example
					catch e
						console.log e.message
						@reply origin, "Unable to find example."
				(err) =>
					@reply origin, "No example found."

		@addRoute "rhyme :word", (origin, route) =>
			if not @swagger.ready
				@reply origin, "Sorry, the Wordnik API isn't ready yet."
				return

			@swagger.apis.word.getRelatedWords
				word: route.params.word
				relationshipTypes: 'rhyme'
				limitPerRelationshipType: 30
				(data) =>
					try
						response = JSON.parse(data.content.data.toString()) # wow gross
						if response.length < 1?
							@reply origin, "No rhymes found."
							return
						rhymes = (word for word in response[0].words).join(", ")
						@reply origin, "These words rhyme with #{route.params.word}: #{rhymes}"
					catch e
						console.log e.message
						@reply origin, "Unable to find ryhmes."
				(err) =>
					@reply origin, "No rhymes found."

		@addRoute "synonym :word", (origin, route) =>
			if not @swagger.ready
				@reply origin, "Sorry, the Wordnik API isn't ready yet."
				return

			@swagger.apis.word.getRelatedWords
				word: route.params.word
				relationshipTypes: 'synonym'
				limitPerRelationshipType: 30
				(data) =>
					try
						response = JSON.parse(data.content.data.toString()) # wow gross
						if response.length < 1?
							@reply origin, "No synonyms found."
							return
						synonyms = (word for word in response[0].words).join(", ")
						@reply origin, "Synonyms of #{route.params.word}: #{synonyms}"
					catch e
						console.log e.message
						@reply origin, "Unable to find synonyms."
				(err) =>
					@reply origin, "No synonyms found."

		@addRoute "antonym :word", (origin, route) =>
			if not @swagger.ready
				@reply origin, "Sorry, the Wordnik API isn't ready yet."
				return

			@swagger.apis.word.getRelatedWords
				word: route.params.word
				relationshipTypes: 'antonym'
				limitPerRelationshipType: 30
				(data) =>
					try
						response = JSON.parse(data.content.data.toString()) # wow gross
						if response.length < 1?
							@reply origin, "No antonyms found."
							return
						antonyms = (word for word in response[0].words).join(", ")
						@reply origin, "antonyms of #{route.params.word}: #{antonyms}"
					catch e
						console.log e.message
						@reply origin, "Unable to find antonyms."
				(err) =>
					@reply origin, "No antonyms found."

		@addRoute "wordoftheday", (origin, route) =>
			if not @swagger.ready
				@reply origin, "Sorry, the Wordnik API isn't ready yet."
				return

			@swagger.apis.words.getWordOfTheDay
				date: new Date().toISOString()[0...10]
				(data) =>
					try
						response = JSON.parse(data.content.data.toString()) # wow gross
						if not response.word?
							@reply origin, "No word of the day?"
							return
						wordoftheday = color.green.bold response.word
						@reply origin, "Today's word of the day: #{wordoftheday}"
					catch e
						console.log e.message
						@reply origin, "Unable to find word of the day."
				(err) =>
					@reply origin, "Error finding word of the day."

		@addRoute "randomwords", (origin, route) =>
			if not @swagger.ready
				@reply origin, "Sorry, the Wordnik API isn't ready yet."
				return

			@swagger.apis.words.getRandomWords
				minLength: 3
				limit: 10
				(data) =>
					try
						response = JSON.parse(data.content.data.toString()) # wow gross
						if response.size is 0
							@reply origin, "No random words?"
							return
						words = color.green (entry.word for entry in response).join(", ")
						@reply origin, "I can think of these off the top of my head: #{words}"
					catch e
						console.log e.message
						@reply origin, "Unable to get random words"
				(err) =>
					@reply origin, "Error getting random words."

		@addRoute "randomwords :pos", (origin, route) =>
			if not @swagger.ready
				@reply origin, "Sorry, the Wordnik API isn't ready yet."
				return
			pos = route.params.pos.toLowerCase()
			if not (pos in partsOfSpeech)
				@reply origin, "That's not a valid part of speech."
				return
			@swagger.apis.words.getRandomWords
				includePartOfSpeech: route.params.pos
				minLength: 3
				limit: 10
				(data) =>
					try
						response = JSON.parse(data.content.data.toString()) # wow gross
						if response.size is 0
							@reply origin, "No random words?"
							return
						words = color.green (entry.word for entry in response).join(", ")
						@reply origin, "I can think of these off the top of my head: #{words}"
					catch e
						console.log e.message
						@reply origin, "Unable to get random words"
				(err) =>
					@reply origin, "Error getting random words."

exports.WordnikModule = WordnikModule