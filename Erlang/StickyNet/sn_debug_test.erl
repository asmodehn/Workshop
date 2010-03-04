-module(stickydebug_test).
-export([start/0]).
-export([testping/1]).
-export([testpong/1]).

-include("stickydebug.hrl").

%%
%% Simple Ping Pong test.
%% The current process is the Control and Command Interface (CCI).
%% Usual Sequential "ping" and then "pong" test.
%% between 2 process, with CCI as a synchronizer
%%
%% Useful to make sure processes can properly communicate, 
%% at least in a sequential manner.
%%

start() ->
	% Choose one only
	%To test the test itself
	%PingPid=spawn(?MODULE,testping,[self()]),
	%PongPid=spawn(?MODULE,testpong,[self()]),
	%to test spawn_debug
	PingPid=stickydebug:spawn_debug(?MODULE,testping,[self()]),
	PongPid=stickydebug:spawn_debug(?MODULE,testpong,[self()]),
	cci_commset(PingPid,PongPid).

%control&command interface
%setting proper Pid for communication
cci_commset(PingPid,PongPid) ->
	io:fwrite(" CCI PID : ~w~n",[self()]),
	PingPid ! {cci,PongPid},
	PongPid ! {cci,PingPid},
	receive
		{ping,commset} ->
			receive
				{pong,commset} -> ok
			end;
		{pong,commset} -> 
			receive
				{ping,commset} -> ok
			end
	end,
	cci_pingpong(PingPid,PongPid).	

%communication is already set, lets do the test itself
cci_pingpong(PingPid,PongPid) ->
	io:fwrite(" CCI Command Ping to : ~w~n",[PingPid]),
	PingPid ! {cci,doping},
	receive
		{pong,gotping} ->
			io:fwrite(" CCI Command Pong to : ~w~n",[PongPid]),
			PongPid ! {cci,dopong}
	end,
	receive
		{ping,gotpong} -> ok 
	end,
	PongPid ! stop,
	PingPid ! stop,
	ok.

%Ping process : wait for Pong PID
testping(CCIPid) ->
	io:fwrite(" Ping PID : ~w~n",[self()]),
	receive
		{cci,PongPid} ->
			CCIPid ! {ping,commset},
			 testping(CCIPid,PongPid)
	end.

%Send ping and wait for pong
testping(CCIPid,PongPid) ->
	receive
		{cci,doping} ->
			io:fwrite("P I N G~n",[]),
			PongPid ! ping,
			testping(CCIPid,PongPid);
		pong ->
			CCIPid ! {ping,gotpong},
			testping(CCIPid,PongPid);
		stop -> ok
	end.

%Pong process : wait for Ping PID
testpong(CCIPid) ->
	io:fwrite(" Pong PID : ~w~n",[self()]),
	receive
		{cci,PingPid} ->
			CCIPid ! {pong,commset},
			 testpong(CCIPid,PingPid)
	end.

%Wait for ping and send pong
testpong(CCIPid,PingPid) ->
	receive
		{cci,dopong} ->
			io:fwrite("P O N G~n",[]),
			PingPid ! pong,
			testpong(CCIPid,PingPid);
		ping ->
			CCIPid ! {pong,gotping},
			testpong(CCIPid,PingPid);
		stop -> ok
	end.


