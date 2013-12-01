# Test dependencies
chai = require 'chai'
expect = chai.expect

# Bot dependencies
PermissionManager = require('../src/core/PermissionManager').PermissionManager

# Instance setup
permManInst = new PermissionManager()

describe 'PermissionManager', ->
	describe '#getParent()', ->
		it 'should return the parent permission of the passed-in one', ->
			permManInst.getParent("machinery.boat.enable").should.equal "machinery.boat"
			permManInst.getParent("machinery.boat").should.equal "machinery"

		it 'should return null when the passed-in permission has no parent', ->
			expect(permManInst.getParent("machinery")).to.equal null
			expect(permManInst.getParent("robot")).to.equal null

	describe '#matchPermissions()', ->
		it 'should consider an explicit permission of a child to be a match', ->
			permManInst.matchPermissions("access.get", "access.get").should.equal true
			permManInst.matchPermissions("machinery.boat.enable", "machinery.boat.enable").should.equal true

		it 'should consider an implicit permission through a parent to be a match', ->
			permManInst.matchPermissions("access", "access.get").should.equal true
			permManInst.matchPermissions("machinery.boat", "machinery.boat.enable").should.equal true
			permManInst.matchPermissions("spaceship.storage", "spaceship.storage.slot.modify.delete").should.equal true

		it 'should consider two different childs not a match', ->
			permManInst.matchPermissions("access.set", "access.get").should.equal false
			permManInst.matchPermissions("machinery.boat.enable", "machinery.car.enable").should.equal false

		it 'should consider two completely different permissions without any shared parents not a match', ->
			permManInst.matchPermissions("lasers.disable", "alderaan.destroy").should.equal false
			permManInst.matchPermissions("channel.user.mode.modify", "pizza.eat").should.equal false

		it 'should consider a single asterisk ("*") to match any permission', ->
			permManInst.matchPermissions("*", "alderaan.destroy").should.equal true
			permManInst.matchPermissions("*", "machinery.boat.enable").should.equal true
			permManInst.matchPermissions("*", "channel.user.mode.modify").should.equal true
			permManInst.matchPermissions("channel.user.mode.destroy", "*").should.equal true