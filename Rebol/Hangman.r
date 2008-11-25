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
	unguessed: [ #"a" #"b" #"c" #"d" #"e" #"f" #"g" #"h" #"i" #"j" #"z"]
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
	
	
	main/pane: [ startup ]

	draw-text: func [ text ] []
	
	start-btn/action: [ main/pane: [ gamerunning ] remake-buttons show main ]	   

	loselife: func [] [

	]	
	
	guess: func [ letter ] [ print "guess"
		found: 0
		alert rejoin [ "char: " letter " wordlength: " length? hangword ]
		repeat pos length? hangword [
		probe letter
		;probe pick hangword pos
			if letter = pick hangword pos 
			[
				alert "found" 
				found: 1
				probe poke hiddenword pos letter
			]
		]
		probe append guessed letter
		probe remove find unguessed letter
		remake-buttons
		if not found [ loselife ]
		show gamerunning						
	] 	
	
	remake-buttons: does [
		print "remake-buttons"
		buttons: copy [
			origin 0x0 
			space 2x2
			backcolor white
			across 
			style btn button 32x32 [ guess to-char face/text ]
		]
		buttonsoff: copy [
			origin 0x0 
			space 2x2
			backcolor white
			across 
			style btn button 32x32
		]
		cnt: 0
		foreach c unguessed [
			repend buttons [ 'btn to-string c ]
			cnt: cnt + 1
			if cnt = 4 [ 
				cnt: 0
				repend buttons [ 'return ]
				probe buttons
			]
		]
		cnt: 0
		foreach c guessed [
			repend buttonsoff [ 'btn to-string c ]
			cnt: cnt + 1
			if cnt = 4 [ 
				cnt: 0
				repend buttonsoff [ 'return ]
				probe buttonsoff
			]
		]
		btn-pane/pane: layout/offset buttons 0x0
		used-pane/pane: layout/offset buttonsoff 0x0
		show btn-pane
		show used-pane
	]
	



	
	;btn-pane/pane: layout/offset [
;		origin 0x0
;		space 0x0
;		across
;		(buttons: copy [ space 0 style btn button 32x32 ]
;		;cnt: 0
;		btn-pane/pane: []
;		foreach c unguessed [
;			;cnt: cnt + 1
;			repend buttons [ 'btn c ]
;			;if cnt = 3 [ return cnt: 0 ]
;		]
;		view/new layout/origin buttons 0x0
;		backcolor red		
;	] 0x0
	


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