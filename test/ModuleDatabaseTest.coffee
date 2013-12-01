
#test dependencies
chai = require 'chai'
chai.should()

#bot dependencies
Module = require('../src/core/Module').Module

#test class
class TestModule extends Module
	shortName: 'test1'
		
	init: () =>
		@x = @newDatabase 'test'

#test class initialization
testModule = new TestModule()
testModule.init()

describe 'ModuleDatabase', ->
	it 'should require a name', ->
		true.should.equal true