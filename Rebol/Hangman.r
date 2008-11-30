REBOL [
	title: "Hangman"
	author: "Asmodehn"
	version: 0.2.0
	date: 26-Nov-2008
	copyright: "Freeware"
]

hangman: context [
	;TODO :  font/image loading
	
	do %Hangman-data.r
	
	main-size: 800x600
	wordlist: [ "croissant" "baguette" ]	
	sound-port: open sound:// 
	max-life: 5
	
	init: does [
		;print "!!! init !!!"
		random/seed now 
		hangword: copy pick wordlist (random length? wordlist)
		hiddenword: copy "" loop (length? hangword) [ append hiddenword "_" ]
		;probe hiddenword
		unguessed: copy [ #"a" #"b" #"c" #"d" #"e" #"f" #"g" #"h" #"i" #"j" #"k" #"l"
					 #"m" #"n" #"o" #"p" #"q" #"r" #"s" #"t" #"u" #"v" #"w" #"x" #"y" #"z"]
		guessed: copy []
		life: max-life
		;probe life
	]

	restart: does [
					hangman/main/pane: [ startup ] 
				    clear hangman/sound-port
					play-sound %Hangman-data/Mortalk1.wav
					view center-face hangman/main
	]

	startup: layout/offset [ 
					origin 0x0
					space 0x0
					size main-size
					backdrop %Hangman-data/TitleScreen.png
					
					at 333x400
					start-btn: button 134x50 %Hangman-data/Start.png backcolor white 
					backcolor green
	] 0x0

	animidle: []
	file-list: read %./Hangman-data/idle/
	foreach file file-list [
		if find to-string file "idle" [
			append animidle rejoin [ %./Hangman-data/idle/ file ]
		]
	]
	
	animcar: []
	file-list: read %./Hangman-data/car/
	foreach file file-list [
		if find to-string file "car" [
			append animcar rejoin [ %./Hangman-data/car/ file ]
		]
	]
	
	animgrenade: []
	file-list: read %./Hangman-data/grenade/
	foreach file file-list [
		if find to-string file "grenade" [
			append animgrenade rejoin [ %./Hangman-data/grenade/ file ]
		]
	]
	
	gamerunning: layout/offset [ 
				origin 0x0
				space 0x0
				size main-size
				anim-pane: box 666x535 red
				
				at 8x525
				life-bar: box 650x60 white
				at 0x535
				word-pane: box 666x65 white
				return			
				btn-pane: box 134x600 white
				backcolor white
	] 0x0
	
	play-anim-idle: does [
		anim-pane/pane: layout/offset [ 
							origin 0x0
							anim 666x535 rate 24 frames animidle effect [ fit ]
						] 0x0
		show anim-pane
	]
	
	play-anim-car: does [
		hide btn-pane
		anim-time: ( length? animcar ) / 24 
		anim-pane/pane: layout/offset [
							origin 0x0
							anim 666x535 rate 24 frames animcar	effect [ fit ]
						] 0x0
		show anim-pane
		wait anim-time
		show btn-pane
		play-anim-idle 
	]

	play-anim-grenade: does [
		hide btn-pane
		anim-time: ( length? animgrenade ) / 24 
		anim-pane/pane: layout/offset [
							origin 0x0
							anim 666x535 rate 24 frames animgrenade	effect [ fit ]
						] 0x0
		show anim-pane
		wait anim-time
		show btn-pane
		play-anim-idle 
	]
	
	draw-life-bar: does [ 
		life-box: reduce [ 'origin 0x0 'space 0x0 'box to-pair rejoin [( 650 * life / max-life ) "x10" ] 'black ] 
		life-bar/pane: layout/offset life-box 0x0
		show life-bar
	] 

	gameover: layout/offset [
				origin 0x0
				space 0x0 
				size main-size
				image %Hangman-data/lose.png [
					restart
				]
				backcolor red	
	] 0x0
 
	gamesuccess: layout/offset [ 
				origin 0x0
				space 0x0
				size main-size
				image %Hangman-data/win.png [
					restart
				] 
				backcolor green
	] 0x0
	
	main: layout [ 
				size main-size 
				title "Hangman"
				backcolor black
	]
	
	start-btn/action: [ 
		init
		main/pane: [ gamerunning ]
		draw-text hiddenword
		remake-buttons
		draw-life-bar
		play-anim-idle
		show main
	]	   

	lose-life: func [] [
		life: life - 1
		draw-life-bar
		show gamerunning
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
		letter-width: 44
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
			repend wordlay [ 'image image-size get to-word rejoin [ letter "_png" ] 'effect [ fit ] ]
		]
		append wordlay [ backcolor white ]
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
		if not found [
			lose-life
			do first random [ play-anim-car play-anim-grenade ]
		]
		
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
			below
			style btn button 44x38 
			style btnoff image 44x38 effect [ fit invert ] 
		]
		append buttons [ image 134x40 %Hangman-data/pick.png return across ]
		cnt: 0
		btn_num: 0
		foreach c unguessed [
			repend buttons [ 'btn get to-word rejoin [ c "_png" ] reduce [ 'guess c ] ]
			cnt: cnt + 1
			btn_num: btn_num + 1
			if cnt = 3 [ 
				cnt: 0
				repend buttons [ 'return ]
			]
		]
		pad-size: 169
		; that is : total size minus ( pick size + guessed size ) minus ( (buttonsize + space ) * num_letters )
		if ( (remainder (length? guessed) 3) <> 0 ) and ( ( remainder ( length? unguessed ) 3) <> 0 ) [
			pad-size: pad-size - 39
		]
		repend buttons [ 'return 'below 'pad pad-size ]
		append buttons [ image 134x40 %Hangman-data/guessed.png return across ]
		cnt: 0
		btn_num: 0
		foreach c guessed [
			repend buttons [ 'btnoff get to-word rejoin [ c "_png" ] ]
			cnt: cnt + 1
			btn_num: btn_num + 1
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
	hangman/restart
]