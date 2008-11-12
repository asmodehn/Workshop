REBOL [Title: "Erlbol Demo"
Author: "Doug Edmunds"
Version: "2008.05.25.01"
Requires: "erlbol.erl as server"]

; ----------Erlbol Section-----------------------------
; --------- Incoming Erlbol functions -----------------

erlbol_in: func [remote]
  [
    if error? 
      try [ wait remote]
  
          [ print "Erlang crashed. See r2e_crash.txt" 
            error_msg:  reform [now {wait remote: Erlang crashed when sent: } b ]
            write/lines/append %r2e_crash.txt error_msg
            wait 5 
          ]
          
    ;get reply from Erlang
    bin_in: copy remote []

    ;debug
    prin "type? bin_in: " print type? bin_in
    prin "bin_in:"  print bin_in

    ;parse reply
    bin_in:  skip bin_in 1 ; the #{83}
    
    ;extract value from reply
    if error? 
      try [
           remote_value: erlbol-parse to-string bin_in
           print type? remote_value print remote_value 
          ] 
      [remote_value: "Error!"
       prin "type? remote_value: " print type? remote_value
       prin "remote_value: " print remote_value]  

    ;debug
    ; remote_value should be #{} if fully converted
    prin "type? remote_value: " print type? remote_value
    prin  "remote_value: " print remote_value  

    ;the output after conversion is sent back to the window
    return remote_value
    ] ;end erlbol_in 


SMALL_INT:   to-string #{61}
INTEGER:     to-string #{62}
FLOAT:       to-string #{63}
ATOM:        to-string #{64}
SMALL_TUPLE: to-string #{68}
NULL:        to-string #{6A}
STRING:      to-string #{6B}
LIST:        to-string #{6C}


erlbol-parse: func [
	str
	/local entity cursor output count data
][
	output: copy ""
	; recursive parse rule
	entity: [
		[
			LIST copy count 4 skip (print "here")
			cursor: ; where do we start parsing next depth
			(
				count: to-integer to-binary count
				append output "["
			)
			; the count for the entity rule was set dynamically
			count entity
			(
				remove/part skip tail output -2 2 ; remove trailing ", " we are at end of a container
				append output "], "
			)
			:cursor ;continue where recursive parses left-off
			NULL
			cursor:
		] |
		[
			SMALL_TUPLE copy count skip
			cursor: ; where do we start parsing next depth
			(
				count: to-integer to-binary count
				append output "{"
			)
			; the count for the entity rule was set dynamically
			count entity
			(
				remove/part skip tail output -2 2 ; remove trailing ", " we are at end of a container
				append output "}, "
			)
			:cursor ;continue where recursive parses left-off
		] |
		[
			STRING copy count 2 skip (
				; here we change the count for the rule dynamically
				count: to-integer to-binary count
			)
			copy data count skip
			cursor: ; where do we continue parsing after these items
			(
        append output rejoin [{"} data {"} ", "]
			)
		] |
		[
			SMALL_INT 
			copy data 1 skip 
			(data:  to-integer to-binary data)
			(probe data )
			cursor: ; where do we continue parsing after these items
			(
        append output join data ", "
			)
		] |
		[
			INTEGER 
			copy data 4 skip 
			(data:  to-integer to-binary data)
			(probe data )
			cursor: ; where do we continue parsing after these items
			(
        append output join data ", "
			)
		] |
		[
			FLOAT 
			copy data 31 skip 
			(data:  to-decimal copy/part data 27)
			(probe data )
			cursor: ; where do we continue parsing after these items
			(
        append output join data ", "
			)
		] |
		[
			ATOM copy count 2 skip (
				; here we change the count for the rule dynamically
				count: to-integer to-binary count
			)
			copy data count skip
			cursor: ; where do we continue parsing after these items
			(
        append output join data ", "
			)
		] 
	]

	parse/all str entity
	remove/part skip tail output -2 2 ; remove trailing ", " we are at end of a container
	return output
]  ; end function erlbol-parse


; do not send any of the following datatypes
; sending one to the parser will result in an error

;    101  ;["reference_ext"]
;    102  ;["port_ext"]
;    103  ;["pid_ext"]
;    105  ;["large_tuple_ext"];

;    109  ;["binary_ext"]
;    110  ;["small_big_ext"]
;    111  ;["large_big_ext"]
    
;     78  ;["new_cache"]
;     67  ;["cached_atom"]
;    114  ;["new_reference_ext"]
;    117  ;["fun_ext"]
;    112  ;["new_fun_ext"]
;    113  ;["export_ext"]
;     77  ;["bit_binary_ext"]
;     70  ;["new_float_ext"]

;---------Outgoing Erlbol functions------------

erlbol_out: func [remote myfields]
  [ send_bin remote make_list_binary myfields]

;Utility function: 
;  converts an integer (int_val) to a length 2 hex value
dec-to-bin: func [int_val]
   [debase/base at to-hex int_val 5 16]

make_list_binary: func [ myfields]
  [
  b_etf:  #{83} ; sending external term format
  b_start_list: #{6C}  ; start list_ext
  b_list_length: debase/base to-hex length? myfields 16 
  b_out: rejoin [b_etf b_start_list b_list_length]
  b_myfield_type: #{6B}
  
  foreach myfield myfields 
    [
     ;debug
     prin "myfield " print  myfield

     myfield_length: dec-to-bin length? myfield
     myfield_text:   to-binary myfield 
     myfield_out: rejoin [b_myfield_type myfield_length myfield_text]
     b_out: rejoin [b_out  myfield_out]
     ]

  b_end_list: #{6A} ; end list_ext with nil_ext
  b_out: rejoin [b_out  b_end_list]

  ;debug
  prin "b_out and type " print b_out print type? b_out
  
  b_out ; return the output
  
] ; end make_list_binary  


;send the binary to Erlang via tcp
send_bin:  func [ remote b_out ] [ insert remote b_out ]


;-----end ERLBOL section-------------------------------------
; do not modify above code unless you know what you're doing
;-----------------------------------------------------------

; --------REBOL window functions ----------

; A function used by the demo window
update_result: func [define_disp remote_value]
    [
    if remote_value = none [quit] ; the 'close window button' is clicked

    define_disp/text: remote_value
    show define_disp
    ]    

; The demo 
; open the Rebol console
print "Opening..."

if error? try [  
  remote: open/binary/direct/no-wait tcp://localhost:4321
  view layout [
        h2   "Erlbol Demo v 2008.05.27.01" 
        h3   "http://erlbol.douglasedmunds.com"
        tabs 60
        across
        label "function" tab
        erl_function: field "add_ints"
        return
        label "field1" tab
        erl_field1: field  "4"
        return
        label "field2" tab
        erl_field2: field  "15"
        return
        label "result area 1" tab
        result1: text wrap "result1 area" 300x50
        return
        label "result area 2" tab
        result2: text wrap "result2 area" 300x50
        return
        button 150 "Use result1" 
            [
            ;Must 'reduce' the block of fields
            myfields:  reduce [erl_function/text erl_field1/text erl_field2/text]
            erlbol_out remote myfields
            erl_reply: erlbol_in remote
            print type? erl_reply
            print erl_reply

            ;Select where to show erl_reply 
            display_in: result1
            update_result display_in erl_reply
            ]
        button 150 "Use result2" 
            [
            ;Must 'reduce' the block of fields
            myfields:  reduce [erl_function/text erl_field1/text erl_field2/text]
            erlbol_out remote myfields
            erl_reply: erlbol_in remote

            ;Select where to show erl_reply  
            display_in: result2
            update_result display_in erl_reply
            ]
        return    
        button "Quit" [quit]
        return
        below
        text "Load erlbol:start() first"
        text "Normally, functions would be embedded in the code."
        text "For this demo, type in one of these functions:"
        text "add_numbers, add_ints, mult_numbers, combine_strings,"
        text "make_list, make_tuple, and put values in the other fields"

        ] 
    
  ]
  [view layout [ h3 "Error making connection"
       text "Unable to open connection to Erlang"
       text "Open Erlang erlbol:start() first"
       ]
  ]    

wait 5   
print "closing"
quit
