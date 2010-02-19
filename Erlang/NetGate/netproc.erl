-module(netproc).
-export([start/0,start_noserver/1,init/2]).
%%
%%
%% This module is a local chat window, that can, if started normally,
%% spawn a netproc_srv.
%% It will communicate to the local netproc_srv via its ePID
%% The server is supposed to manage sending messages to other servers using
%% NetGate peer-to-peer protocol.
%%
%% An extension is planned to connect to an existing remote server,
%% through sockets, in a more traditional client - server manner.
%%

start() ->
    io:format("Starting local server ...",[]),
    SrvPid = stickydebug:spawn_debug(netproc_srv,init,[self()]),
    start_noserver(SrvPid).

start_noserver(SrvPid) ->
    io:format("Starting local client ...",[]),
    stickydebug:spawn_debug(netproc,init,[self(),SrvPid]).

init(Pid,SrvPid) ->
    gui_create(Pid,SrvPid).

gui_create(Pid,SrvPid) ->
    %the connection might generate a new process to be created
    Newsrvpid = server_connect(SrvPid),
    %TODO : separate client connection and GUI
    %but this require one more process...

    %creating the GUI
    S=gs:start(),
    Win=gs:window(S,[{title,"NetProc Tests"},{width,300},{height,600}]),
    gs:create(editor,chat,Win,[{height,500}, {width,280}, {x,10}, {y,60}]),
    gs:create(entry,entry,Win,[{x,10},{y,560},{width,280},{keypress,true}]),
    gs:config(chat,{vscroll,right}),
    gs:config(Win,{map,true}),
    loop(Pid,Newsrvpid).

gui_write(Text) ->
	    Insrow=gs:read(chat,size),
	    gs:config(chat,{insert,{{Insrow,0},Text}}),
	    gs:config(chat,{vscrollpos,Insrow - gs:read(chat,char_height)}).

server_connect(Pid) ->
	io:fwrite("Initiating Local Connection to ~w~n",[Pid]),
 	%gui_write("Initiating Local Connection to ~w~n",[Pid]),	
	Pid ! {connect,self()},
	receive
	{connect,SrvPid} -> SrvPid
		%gui_write("Server Found, PID :" ++ srvpid )
	end,
	SrvPid.


loop(Pid,SrvPid) ->
    %waiting on events
    receive
	{gs,entry,keypress,_,['Return'|_]} ->
	    %sending the text to the server
	    Text=lists:append([gs:read(entry,text),"\n"]),
	    SrvPid ! {netproc,Text},
	    %displaying the text on the GUI
	    gui_write(Text),
	    %clearing the entry field
	    gs:config(entry,{delete,{0,length(Text)}}),
	    loop(Pid,SrvPid);
	{gs,entry,keypress,_,_} ->
	    loop(Pid,SrvPid);
	{gs,_,destroy,_,_} ->
	    Pid ! {exit_display,"window_closed"},
	    exit(normal);
	X ->
	    io:format("Got X=~w~n",[X]),
	    loop(Pid,SrvPid)
    end.


