REBOL [
	title: "Hangman"
	author: "Asmodehn"
	version: 0.2.0
	date: 26-Nov-2008
	copyright: "Freeware"
]

hangman: context [
	;TODO :  font/image loading
	main-size: 800x600
	wordlist: [ "croissant" "baguette" ]	
	sound-port: open sound://
	max-life: 5 

	init: does [
		print "!!! init !!!"
		random/seed now 
		hangword: copy probe pick wordlist (random length? wordlist)
		hiddenword: copy "" loop (length? hangword) [ append hiddenword "_" ]
		probe hiddenword
		unguessed: copy [ #"a" #"b" #"c" #"d" #"e" #"f" #"g" #"h" #"i" #"j" #"k" #"l"
					 #"m" #"n" #"o" #"p" #"q" #"r" #"s" #"t" #"u" #"v" #"w" #"x" #"y" #"z"]
		guessed: copy []
		life: copy max-life
		
		probe life
	]

	startup: layout/offset [ 
					origin 0x0
					space 0x0
					size main-size
					image 666X535 %Hangman-data/stick0.bmp effect [ fit ] 
					image 666x65 %Hangman-data/title.png effect [ fit ]
					return
					start-btn: button 134x50 %Hangman-data/Start.png backcolor white 
					backcolor green
	] 0x0
	
	gamerunning: layout/offset [ 
				origin 0x0
				space 0x0
				size main-size
				anim 666x535 rate 10 frames [ 
					%Hangman-data/walking/walking00.png
					%Hangman-data/walking/walking01.png
					%Hangman-data/walking/walking02.png
					%Hangman-data/walking/walking03.png
					%Hangman-data/walking/walking04.png
					%Hangman-data/walking/walking05.png
					%Hangman-data/walking/walking06.png
					%Hangman-data/walking/walking07.png
					%Hangman-data/walking/walking08.png
					%Hangman-data/walking/walking09.png
					%Hangman-data/walking/walking10.png
					%Hangman-data/walking/walking11.png
					%Hangman-data/walking/walking12.png
				] effect [ fit ]
				word-pane: box 666x65 red
				return			
				btn-pane: box 134x535 coal
				backcolor blue
	] 0x0 

	gameover: layout/offset [
				origin 0x0
				space 0x0 
				size main-size
				image %Hangman-data/lose.png [
					main/pane: [ startup ] 
					clear sound-port
					play-sound %Hangman-data/Mortalk1.wav					
				    view center-face hangman/main
				]
				backcolor red	
	] 0x0
 
	gamesuccess: layout/offset [ 
				origin 0x0
				space 0x0
				size main-size
				image %Hangman-data/win.png [
					main/pane: [ startup ] 
				    clear sound-port
					play-sound %Hangman-data/Mortalk1.wav
					view center-face hangman/main
				] 
				backcolor green
	] 0x0
	
	main: layout [ 
				size main-size 
				title "Hangman"
				backcolor black
	]
	main/pane: [ startup ]
	
	start-btn/action: [ 
		init
		main/pane: [ gamerunning ]
		draw-text hiddenword
		remake-buttons
		show main
	]	   

	lose-life: func [] [
		life: life - 1
	]	

	play-sound: func [ wavfile ] [
	    if error? err: try [
    	    wav: load wavfile
			clear sound-port        	
			insert sound-port wav
	        ;wait sound-port
	        
	        true
	    ][
	        print ["ERROR:" mold disarm err]
	        ask "Press return to continue"
	    ]
	]
	
	draw-text: func [ strword ] [
		;compute this with max size of possible word
		letter-width: 32
		word-width: letter-width * length? hangword
		wordlay: copy [
			origin to-pair rejoin [ (reduce (word-pane/size/1 - word-width) / 2 ) "x" "0" ]
			space 0x0
			size word-pane/size
			across
		]
		image-height: word-pane/size/2
		image-size: to-pair rejoin [letter-width "x" image-height]
		foreach letter strword [
			repend wordlay [ 'image image-size rejoin [ %Hangman-data/ letter ".png" ] 'effect [ fit ] ]
		]
		word-pane/pane: layout/offset wordlay 0x0
		show word-pane
	]
	
	guess: func [ letter ] [
		found: false
		repeat pos length? hangword [
			if letter = pick hangword pos 
			[
				found: true
				poke hiddenword pos letter
			]
		]
		append guessed letter
		remove find unguessed letter
		draw-text hiddenword
		remake-buttons
		show gamerunning
		if not found [ lose-life ]
		
		if/else life = 0 [
			main/pane: [ gameover ]
			play-sound %Hangman-data/epic_fail.wav
			show main
		][
			if not find hiddenword "_"
			[
				main/pane: [ gamesuccess ]
				play-sound %Hangman-data/flawless_victory.wav
				show main
			]
		]
	] 	
	
	remake-buttons: does [
		buttons: copy [
			origin 0x0 
			space 1x1
			backcolor white
			across 
			style btn button 44x38 ;[ guess to-char face/text ]
			style btnoff button 44x38
		]
		append buttons [ return image 134x40 %Hangman-data/pick.png return ]
		cnt: 0
		foreach c unguessed [
			repend buttons [ 'btn rejoin [ %Hangman-data/ c ".png" ] reduce [ 'guess c ] ]
			cnt: cnt + 1
			if cnt = 3 [ 
				cnt: 0
				repend buttons [ 'return ]
			]
		]
		append buttons [ return image 134x40 %Hangman-data/guessed.png return ]
		cnt: 0
		foreach c guessed [
			repend buttons [ 'btnoff rejoin [ %Hangman-data/ c ".png" ]]
			cnt: cnt + 1
			if cnt = 3 [ 
				cnt: 0
				repend buttons [ 'return ]
			]
		]
		btn-pane/pane: layout/offset buttons 0x0
		show btn-pane
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
	    clear hangman/sound-port
		hangman/play-sound %Hangman-data/Mortalk1.wav
		view center-face hangman/main
]