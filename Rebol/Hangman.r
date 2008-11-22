REBOL [
	title: "Hangman"
	author: "Asmodehn"
	version: 0.0.1
	date: 15-Nov-2008
	copyright: "Freeware"
]

rebomb: context [
	sprite-size: 20x20
	pause: no
	
	init: reduce [ random/seed now ]

	; the main layout. originally with startup face. will hcange later based on game state
	lay: make face [
			size: 400x400
			text: "ReBomb"
			pane: [ startup ]		 
	]

	startup: layout [
				text "Hangman"
				button "Start" [ lay/pane: [ gamerunning ] show lay ]
		]

	gamerunning: layout[ box red 200x200 ]

	gameover: make face []

	gamesuccess: make face []

]

insert-event-func func [face event] bind [
	if all [
		event/type = 'key
		not system/view/focal-face
		find [ #"p"] event/key
		(not pause) or (event/key = #"p")
	] [
		switch event/key [
		#"p"	[pause: not pause]
		]
		return none
	]
	event
] in rebomb 'self

if any [not system/script/args empty? form system/script/args] [
	rebomb/init
    view center-face rebomb/lay
]