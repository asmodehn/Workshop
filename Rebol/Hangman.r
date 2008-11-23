REBOL [
	title: "Hangman"
	author: "Asmodehn"
	version: 0.1.1
	date: 15-Nov-2008
	copyright: "Freeware"
]

hangman: context [
	sprite-size: 20x20
	text-size: 18
	;TODO :  font loading
	main-size: 320x240
	pause: no
	hangword: "hangman"
	letter-list: ['a 'b 'c 'd ]

	init: reduce [ random/seed now ]

	faces: context[	
		start-btn:  make face [
					image: load %Hangman-data/Start.png
					effect: [ fit ]
					color:yellow
					action: [ view layout [ text "yop" ] ]
				]
		hangpic: make face [
					image: load %Hangman-data/stick0.bmp 
					effect: [ fit ]
					color:blue
				]
		hangtitle: make face [
					text: "Hangman"
					color: red
				]
	]
	

	debug: layout [    
			    label "Debug:"
			    console: field 100 [attempt [do console/text]]
	]


	;startup layout
	startup: make face [
				offset: 0x0
				size: main-size
				color: green
				pane: reduce [
					faces/hangpic
					faces/hangtitle
					faces/start-btn
				]
			]
			faces/hangtitle/offset: 0x100
			faces/hangtitle/size: 100x20
			faces/start-btn/offset: 0x150
			faces/start-btn/size: 100x30
			;faces/start-btn/action: 

	gamerunning: layout [
				text hangword
				text "letters used"				
				text "Choose a letter"
				]

	gameover: make face []

	gamesuccess: make face []

	; the main layout. originally with startup face. will change based on game state
	lay: make face [
			offset: 0x0
			color: black
			size: main-size
			text: "Hangman"
			pane: reduce [ startup ]
	]

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
] in hangman 'self

if any [not system/script/args empty? form system/script/args] [
	hangman/init
    view center-face hangman/lay
]