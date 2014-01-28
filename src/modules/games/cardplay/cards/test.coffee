ready (addCard) ->

	card = addCard 'unit', "se.kayarr.tester_of_worlds",
		name: "Tester of Worlds"

		desc: "On entry, heals user 20 HP."

		flavor: """
			His less destructive tendencies compared to his brethen
			made him a lot more popular among the townspeople.
		"""

	card.on 'entry', (unit) ->

		unit.owner.hp += 20