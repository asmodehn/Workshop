-module(netproc_srv).
-export([start/0,init/1]).

%%
%% This module is a NetGate server prototype.
%% It communicates with other NetGate servers, reorders the messages it receives
%% and display them to all clients that previously connected to him
%%
%%
%%Local client can initiate the server through init() methods
%%


%start methods are used for standalone server
%start() will autodetect other servers
start() ->
	%TODO : UDP broadcast to detect other servers
	%TMP : for now, no external connection
	io:format("Starting local server ...",[]),
	SrvPid = spawn_link(netproc_srv,init,[self()]),
    	io:format("PID : ~w~n",[SrvPid]),
	waitfinish().

%start(remoteIP,remotePort) will connect to a specific server and get
start(remoteIP,remotePort) ->
	%TMP : for now, no external connection
	io:format("Starting local server ...",[]),
	SrvPid = spawn_link(netproc_srv,init,[self()]),
    	io:format("PID : ~w~n",[SrvPid]),
	waitfinish().

waitfinish() ->
	process_flag(trap_exit,true),
	receive
	%waiting for a message to be displayed on exit
	{'EXIT',FromPid,Reason} ->
		io:format("Exit Signal from ~w because ~w~n",[FromPid,Reason]);
	X ->
	    io:format("Got X=~w~n",[X])
	end.
		


%init ip port used for standalone server	
%init(Pid) ->
	
	
% local client will communicate through pid
% remote servers will communicate through sockets.
init(Pid) ->
	listen (Pid).


handlemsg(Pid,LCpid) ->
	io:format("params : ~w ~w~n",[Pid,LCpid]),
	receive
  	{netproc,Msg} ->
		io:format("Got NetProc Msg=~w~n",[Msg]),
		handlemsg(Pid,LCpid);
	X ->
	    io:format("Got X=~w~n",[X]),
	    handlemsg(Pid,LCpid)
	end.

listen(Pid) ->
	receive
	{connect,LCpid} when is_pid(LCpid) ->
		io:format("Got Connection request from ~w~n",[LCpid]),
		%for now in same thread -> accepting only one local client
		LCpid ! {connect,self()},
		handlemsg(Pid,LCpid);
	X ->
	    io:format("Got X=~w~n",[X]),
	    listen(Pid)
	end.

