# Test dependencies
chai = require 'chai'
expect = chai.expect

# Bot dependencies
bot = require '../kurea'

# Instance setup
permissionManager = new bot.PermissionManager()

describe 'PermissionManager', ->
	describe '#getParent()', ->
		it 'should return the parent permission of the passed-in one', ->
			permissionManager.getParent("machinery.boat.enable").should.equal "machinery.boat"
			permissionManager.getParent("machinery.boat").should.equal "machinery"

		it 'should return null when the passed-in permission has no parent', ->
			expect(permissionManager.getParent("machinery")).to.equal null
			expect(permissionManager.getParent("robot")).to.equal null

	describe '#matchPermissions()', ->
		it 'should consider an explicit permission of a child to be a match', ->
			permissionManager.matchPermissions("access.get", "access.get").should.equal true
			permissionManager.matchPermissions("machinery.boat.enable", "machinery.boat.enable").should.equal true

		it 'should consider an implicit permission through a parent to be a match', ->
			permissionManager.matchPermissions("access", "access.get").should.equal true
			permissionManager.matchPermissions("machinery.boat", "machinery.boat.enable").should.equal true
			permissionManager.matchPermissions("spaceship.storage", "spaceship.storage.slot.modify.delete").should.equal true

		it 'should consider two different childs not a match', ->
			permissionManager.matchPermissions("access.set", "access.get").should.equal false
			permissionManager.matchPermissions("machinery.boat.enable", "machinery.car.enable").should.equal false

		it 'should consider two completely different permissions without any shared parents not a match', ->
			permissionManager.matchPermissions("lasers.disable", "alderaan.destroy").should.equal false
			permissionManager.matchPermissions("channel.user.mode.modify", "pizza.eat").should.equal false