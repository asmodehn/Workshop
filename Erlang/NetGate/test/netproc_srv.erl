-module(netproc_srv).
-export([start/0,init/1]).

%%
%% This module is a NetGate client prototype.
%% It s actually a server to applicative clients.
%% It communicates with other NetGate servers, reorders the messages it receives
%% and display them to all local clients that previously connected to him
%%
%%
%% Local client can initiate the server through init() methods
%% They need to send a {connect,Pid} message to the server to initiate
%% a connection.
%%


%start methods are used for standalone server
%start() will autodetect other servers
start() ->
	%TODO : UDP broadcast to detect other servers
	%TMP : for now, no external connection
	io:format("Starting local server ...~n",[]),
	stickydebug:spawn_debug(netproc_srv,init,[self()]).

%start(remoteIP,remotePort) will connect to a specific server and get
start(remoteIP,remotePort) ->
	%TMP : for now, no external connection
	io:format("Starting local server ...~n",[]),
	stickydebug:spawn_debug(netproc_srv,init,[self()]).

%init ip port used for standalone server	
%init(Pid) ->
	
	
% local client will communicate through pid
% remote servers will communicate through sockets.
init(Pid) ->
	listen(self()),
	
	%% netgate : W.I.P
	%io:format("Opening Gate ...",[]),
	%GatePid = stickydebug:spawn_debug(netgate,open,[self()]).
	
	ok.

listen(Pid) ->
	io:format("~w Listening for local clients ...~n",[self()]),
	receive
	{connect,LCpid} when is_pid(LCpid) ->
		io:format("Got Connection request from ~w~n",[LCpid]),
		%for now in same thread -> accepting only one local client
		handlecnx(Pid,LCpid);
	X ->
	    io:format("Got X=~w~n",[X]),
	    listen(Pid)
	end.

handlecnx(Pid,LCpid) ->
	%accepting connection
	LCpid ! {connect,self()},
	handlemsg(Pid,LCpid).

handlemsg(Pid,LCpid) ->
	receive
  	{netproc,Msg} ->
		io:fwrite("~w : ~s~n",[LCpid,Msg]),
		handlemsg(Pid,LCpid);
	{gate,Msg} ->
		%retransmitting message from NetGate
		Pid ! {netproc,Msg};
	X ->
	    io:fwrite("Got X=~w~n",[X]),
	    handlemsg(Pid,LCpid)
	end.

