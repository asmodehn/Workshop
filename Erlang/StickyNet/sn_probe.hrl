-export([start/0,loop_getnodes/0]).

-include("stickynet.hrl").

%%
%% This header is an self-test include for the StickyNet_Probe module in erlang.
%%
%% start() will launch a new StickyNet_Probe, if one doesnt already exists.
%% wait() will report wich stickynet nodes have been detected.
%% stop() will stop all processes started by start(), and terminate the process.
%%

start() ->
	Piddisp =sn_debug:spawn_debug(?MODULE,loop_getnodes,[]),
	{Sock,PidR,PidC} = init(Piddisp),
	link(PidR),
	link(PidC),
	process_flag(trap_exit,true),
	wait({Sock,PidR,PidC},Piddisp).

wait({Sock,PidR,PidC},Piddisp) ->
	receive
	{'EXIT',FromPid,Reason} ->
		io:fwrite("Exit signal from ~w, Reason ~w.~n",[FromPid,Reason]),
		wait({Sock,PidR,PidC},Piddisp)
	after 20000 ->
		io:fwrite("Test Timeout reached. Exiting.~n")
	end,
	stop({Sock,PidR,PidC},Piddisp).

stop({Sock,PidR,PidC},Piddisp) ->
	Piddisp ! stop,
	fin({Sock,PidR,PidC}).
		
loop_getnodes() ->
	receive
		{stickynode,IP,Data} ->
           		io:format("~n~nNode: ~p~nData: ~p~n",[IP,Data]),
			loop_getnodes();
		stop -> ok
	end.
	
