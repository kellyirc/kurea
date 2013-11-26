
class TestModule extends Module
	@shortName = 'test'
	constructor: () ->
		x = super.newDatabase 'test'

chai = require 'chai'
chai.should()

bot = require '../kurea.coffee'

testModule = new TestModule()

describe 'ModuleDatabase', ->
	it 'should require a name', ->
		true.should.equal true