-module(netproc).
-export([start/0,start_noserver/1,gui_init/2]).
-export([conx_init/2]).

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


%%
%% Design : 
%%
%% start() 
%%
%%
start() ->
    io:format("Starting local server ...~n",[]),
    SrvPid = stickydebug:spawn_debug(netproc_srv,init,[self()]),
    start_noserver(SrvPid).

start_noserver(SrvPid) ->
    io:format("Starting local client ...~n",[]),
    stickydebug:spawn_debug(netproc,gui_init,[self(),SrvPid]).

%gui management process
gui_init(Pid,SrvPid) ->
    %creating the GUI
    S=gs:start(),
    Win=gs:window(S,[{title,"NetProc Tests"},{width,300},{height,600}]),
    gs:create(label,status_label,Win,[	{label,{text,"Status :"}},
					{height,40},{width,280},
					{x,10}, {y,10}	]),
    gs:create(editor,chat,Win,[{height,500}, {width,280}, {x,10}, {y,60}]),
    gs:create(entry,entry,Win,[{x,10},{y,560},{width,280},{keypress,true}]),
    gs:config(chat,[{vscroll,right}]),
    gs:config(Win,{map,true}),

    %spawning connexion management process
    Newsrvpid = stickydebug:spawn_debug(netproc,conx_init,[self(),SrvPid]),

    gui_loop(Pid,Newsrvpid).

gui_write(Text) ->
	    Insrow=gs:read(chat,size),
	    gs:config(chat,[{insert,{{Insrow,0},Text}}]),
	    gs:config(chat,[{vscrollpos,Insrow - gs:read(chat,char_height)}]).

gui_labelchange(Text) ->
	gs:config(status_label,[{label,{text,Text}}]).

gui_loop(Pid,SrvPid) ->
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
	    gui_loop(Pid,SrvPid);
	{gs,entry,keypress,_,_} ->
	    gui_loop(Pid,SrvPid);
	{gs,_,destroy,_,_} ->
	    Pid ! {exit_display,"window_closed"},
	    exit(normal);
	{conx,statusmsg,Msg} ->
	    gui_labelchange("Status : " ++ Msg),
	    gui_loop(Pid,SrvPid);
	X ->
	    io:format("Got X=~w~n",[X]),
	    gui_loop(Pid,SrvPid)
    end.

%server connexion management process
conx_init(GUIPid,SrvPid) when is_pid(GUIPid) and is_pid(SrvPid) ->
 	
	GUIPid ! {conx,statusmsg,"Initiating Local Connection to " ++ pid_to_list(SrvPid) },
	SrvPid ! {connect,self()},
	receive
	{connect,NewSrvPid} -> 
		GUIPid ! {conx,statusmsg,"Server Found, PID :" ++ pid_to_list(NewSrvPid)}
	end,
	conx_watch(GUIPid,SrvPid).

conx_watch(GUIPid,SrvPid) ->
	receive
		%message from the gui
		{netproc,Text} -> 
		SrvPid ! {netproc,Text},
		conx_watch(GUIPid,SrvPid);
		%message from the server
		{conx,statusmsg,X} -> 
		GUIPid ! {conx,statusmsg,X},
		conx_watch(GUIPid,SrvPid)
	end.


