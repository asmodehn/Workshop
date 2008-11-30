rebol []
system/options/binary-base: 64  
data: copy []

folder: %./Hangman-data/

compress-data: does [
	
	file-list: read folder
	foreach file file-list [
		if not find to-string file ".svn" [
			append data rejoin [ file ":" ]
			uncompressed: read/binary rejoin [ folder file ]
			compressed: compress to-string uncompressed
			append data compressed
		]
	]	
]

;TODO : if folder, recurse...

compress-data
editor data
