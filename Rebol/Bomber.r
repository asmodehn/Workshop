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
		size: 400x300
		panel: 200x200
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
] in rebomb 'self

if any [not system/script/args empty? form system/script/args] [
	random/seed now
	rebomb/init
    view layout rebomb/lay
]