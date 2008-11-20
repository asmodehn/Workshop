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
	
	init: func [/local ex] [
		layout [
			stone: image (sprite-size) 200.200.0 effect [gradient 1x1 200.200.0 100.100.0]
		]
	]

	lay: [
		origin 0x0 space 0x0 across 
		box black 200x200
	]
	

]



;view center-face gui: layout [
;    origin 0x0 space 0x0 across 
;;    style p button 60x60 [
;        if not find [0x60 60x0 0x-60 -60x0] 
;            face/offset - empty/offset [exit]
;        temp: face/offset face/offset: empty/offset 
;            empty/offset: temp
;    ]
;;    p "A" p "B" p "C" p "D" return p "E" p "F" p "G" p "H" return
;    p "I" p "J" p "K" p "L" return p "M" p "N" p "O"  
;    empty: p 200.200.200 edge [size: 0]
;]



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
    view center-face layout/size rebomb/lay 200x200
]