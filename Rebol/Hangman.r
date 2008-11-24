REBOL [
	title: "Hangman"
	author: "Asmodehn"
	version: 0.1.1
	date: 15-Nov-2008
	copyright: "Freeware"
]

hangman: context [
	sprite-size: 20x20
	;TODO :  font loading
	main-size: 640x480
	hangword: "hangman"
	hiddenword: "________"
	unguessed: [ #"a" - #"z"]
	guessed: []

	init: reduce [ random/seed now ]

	hideword: func [] [ 
	
	]

	startup: layout/offset [
					origin 0x0
					space 0x0
					size main-size
					image %Hangman-data/stick0.bmp effect [ aspect ] 
					image 506x65 %Hangman-data/title.png effect [ fit ]
					return
					start-btn: button 134x50 %Hangman-data/Start.png backcolor white 
					backcolor green
	] 0x0

	gamerunning: layout/offset [  
				origin 0x0
				space 0x0
				size main-size
				image %Hangman-data/stick0.bmp effect [ aspect ]
				text hiddenword bold red
				return			
				btn-pane: box 134x200 coal
				text "Already guessed:" 
				used-pane: box 134x200 coal
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

	main/pane: [ startup ]


	draw-text: func [ text ] []

	guess: func [ letter ] [
		alert rejoin [ "char:" letter " wordlength: " length? hangword ]

		repeat pos length? hangword [
        if/else letter = pick hangword pos 
		[
			alert "found" 
			poke hiddenword pos letter
		]
		[ 
			alert "notfound"
			 loselife
		]
		append guessed letter
		remove unguessed letter
      ]
		
		show gamerunning						
	] 	
	
	loselife: func [] [

	]	

	btn-pane/pane: layout/offset [
		origin 0x0
		space 0x0
		style btn button 32x32
		btn "a" [ guess #"a" ]
		backcolor red		
	] 0x0	


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