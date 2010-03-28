-module(process_test).

-author('Alexandre VINCENT <alex@asmodehn.com>').

-export([start/0]).


%This tests relative ordered communication in a set of process.

start(String)







init_process() ->
	spawn().

p_run(String) ->
	receive
	%end of test : return ordered string
	{'FINISH',PPid} -> proc_send( PPid, String);
	%test command : send Message (character)
	{'SEND',Msg,ToPid} -> ToPid ! Msg, p_run( String ++ Msg);
	%test receive message : put in local string
	Msg -> p_run(String ++ Msg)
	end.


