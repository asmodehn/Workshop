REBOL [
	title: "ReBomb"
	author: "Asmodehn"
	version: 0.0.1
	date: 15-Nov-2008
	copyright: "Freeware"
]

rebomb: context [
	sprite-size: 20x20
	pause: no
	
	init:

	; the main layout. originally with startup face. will hcange later based on game state
	lay: make face [
			size: 400x400
			text: "ReBomb"
			pane: [ startup ]		 
	]

	startup: layout [
				text "ReBomb"
				button "Start" [ hide startup show gamerunning ]
		]

	gamerunning: make face [] 

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
	random/seed now
	rebomb/init
    view center-face rebomb/lay
]