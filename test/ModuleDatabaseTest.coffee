###
#test dependencies
fs = require 'fs'
rimraf = require 'rimraf'

chai = require 'chai'
chai.should()

expect = chai.expect

#bot dependencies
Module = require('../src/core/Module').Module

#test class
class TestModule extends Module

	shortName: 'test-module'

	constructor: (@dbName) ->
		
	init: () =>
		@testDb = @newDatabase @dbName

describe 'ModuleDatabase', ->

	after (done) ->
		rimraf 'data/test-module', ->
			done()

	#name is not checked because it requires the db to be created instantly 
	#destroy is not checked because it requires the db to be created instantly

	it 'should require a valid name', ->
		testModule = new TestModule()
		expect(testModule.init).to.throw Error

		testModule = new TestModule ''
		expect(testModule.init).to.throw Error

		testModule = new TestModule 'test'
		expect(testModule.init).to.not.throw Error 

	it 'should insert data into a database', ->
		testModule = new TestModule 'insert-test'
		testModule.init()

		testModule.testDb.insert {data: 'hello!'}, (error, item) ->
			expect(error).to.equal null

	it 'should find data in a database', ->
		testModule = new TestModule 'find-test'
		testModule.init()

		testModule.testDb.insert {data: 'hello!'}, ->
			testModule.testDb.find {data: 'hello!'}, (error, items) ->
				expect(error).to.equal null
				items.should.not.equal []

	it 'should remove data from a database', ->
		testModule = new TestModule 'remove-test'
		testModule.init()

		testModule.testDb.insert {data: 'hello!'}, ->
			testModule.testDb.remove {data: 'hello!'}, {multi: true}, (error, removedCount) ->
				expect(error).to.equal null
				removedCount.should.be.at.least 1

	it 'should count data rows matching a criteria in the database', ->
		testModule = new TestModule 'count-test'
		testModule.init()

		testModule.testDb.insert {data: 'hello!'}, ->
			testModule.testDb.count {},  (error, count) ->
				expect(error).to.equal null
				count.should.be.at.least 1

	it 'should update data rows matching a criteria in the database', ->
		testModule = new TestModule 'update-test'
		testModule.init()

		testModule.testDb.insert {data: 'hello!'}, ->
			testModule.testDb.update {data: 'hello!'}, {$set: {data: 'hello.'}}, {multi: true}, (error, count) ->
				expect(error).to.equal null
				testModule.testDb.count {data: 'hello!'},  (error, count) ->
					count.should.equal 0
				testModule.testDb.count {data: 'hello.'},  (error, count) ->
					count.should.be.at.least 1
###