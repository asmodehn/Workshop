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
	main-size: 800x600
	hangword: "hangman"
	letter-list: ['a 'b 'c 'd ]

	init: reduce [ random/seed now ]


	startup: layout/offset [
					origin 0x0
					space 0x0
					size main-size
					image %Hangman-data/stick0.bmp effect [ aspect ] 
					image %Hangman-data/title.png effect [ aspect ]
					across
					start-btn: button %Hangman-data/Start.png backcolor white 
					backcolor green
	] 0x0

	gamerunning: layout/offset [  
				size main-size
				text hangword
				text "letters used"				
				text "Choose a letter"
				backcolor blue
	] 0x0

	gameover: layout/offset [
				size main-size
				backcolor red	
	] 0x0
 
	gamesuccess: layout/offset [ 
				size main-size
				backcolor purple
	] 0x0
	
	main: layout [
				size main-size 
				title "Hangman"
				backcolor black
	]
	
	;start-btn: layout [ 
	;				button %Hangman-data/Start.png backcolor white
					;[ alert "click" ] 
					;[ main/pane: [ gamerunning ] show gamerunning ]
					
	;]
	;append startup/pane start-btn
	start-btn/action: [ main/pane: [ gamerunning ] show main ]	 
	show startup  

	main/pane: [ startup ]
	show center-face main

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
    view center-face hangman/main
]