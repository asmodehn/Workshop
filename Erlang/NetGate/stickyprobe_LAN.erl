-module(stickyprobe_LAN).
-export([init/1,fin/1,open/2,close/1,getlocalif/1,receiver/2,caster/2]).

%%including selftest header
-include("stickyprobe.hrl").

%%
%% This module is a StickyProbe implementation in erlang.
%% It can detect other StickyNet nodes, and inform it s parent, usually
%% stickynet.
%% 

%%
%% In Erlang, the API is provided through message passing to the main process
%% the process running start() will act as a message receiver ( for debug purpose ).
%% Run init() in a separate process from the client if you want direct message
%% channel to get notification of detected nodes
%%

%% Initialize StickyProbe to detect other StickyNodes
init(Pid) ->
	io:fwrite("~w StickyProbe : Starting... ~n",[self()]),
	%% finding Addresses
	{inet,LocalIP,Broadcast,Mask} = getlocalif(inet),
	%{inet6,LocalIPv6,Maskv6} = getlocalif(inet6),

	%% autodetection of other nodes
	Sock = open(LocalIP,?STICKY_PROBE_PORT),
	PidR = spawn(?MODULE,receiver,[Sock,Pid]),
   	ok = gen_udp:controlling_process(Sock,PidR),
	PidC = spawn(?MODULE,caster,[Sock,Broadcast]),
	{Sock,PidR,PidC}.
	%%Calling process must then wait and receive message, just like start() is doing here

%% Finalize StickyProbe, and exit.
fin({S,PidR,PidC}) ->
	io:fwrite("~w StickyProbe : Stopping... ~n",[self()]),
	process_flag(trap_exit,true),

	link(PidC),
	PidC ! stop,
	receive
	{'EXIT',FromPidC,ReasonC} ->
		io:fwrite("Exit signal from ~w, Reason ~w.~n",[FromPidC,ReasonC])
	end,

	link(PidR),
	PidR ! stop,
	receive
	{'EXIT',FromPidR,ReasonR} ->
		io:fwrite("Exit signal from ~w, Reason ~w.~n",[FromPidR,ReasonR])
	end,
	close(S).

%this return the proper IP Address for Stickyprobe to consider
% Ipv6 TODO
getlocalif(InetV)->
	{ok,Addrs} = inet:getif(),
	%case InetV of
	%	inet ->
	%		{ok,Addrs} = inet:getif();
	%	inet6 ->
	%	%	{ok,Addrs} = inet:getif6()
	%		io:fwrite("Not Implemented yet")
	%end,
	{ok,Hostname} = inet:gethostname(),
   	io:fwrite("Hostname : ~s ~n Addresses : ~w ~n",[Hostname,Addrs]),
	{IPAd,BcAd,Mask} = filterif(Addrs),
   	io:fwrite("Filtered Addresses : ~n",[]),
   	io:fwrite("Local IP Address : ~w ~n",[IPAd]),
   	io:fwrite("Broadcast Address : ~w ~n",[BcAd]),
   	io:fwrite("Mask : ~w ~n",[Mask]),
	{inet,IPAd,BcAd,Mask}.
	

%extractingly proper address(es)
filterif(AddrList) -> parseif(AddrList,[]).
parseif([If1|T],IPList) ->
	{LocalIP,BroadIP,_} = If1,
	case LocalIP of
		{127,0,0,1} -> parseif(T,IPList);
		{_,_,_,_} -> parseif(T,IPList ++ If1)
	end;
parseif([],BcIPList) -> BcIPList.

open(Addr,Port) ->
   %{ok,IP} = inet_parse:address(Addr),
   %DOESNT SEEM TO WORK WITH IP... why ?
   %{ok,S} = gen_udp:open(Port,[{reuseaddr,true}, {ip,Addr}, {broadcast,true}, binary]),
   {ok,S} = gen_udp:open(Port,[{reuseaddr,true}, {broadcast,true}, binary]),
   S.

close(S) -> gen_udp:close(S).

receiver(Sock,Pid) ->
	io:fwrite("~w StickyProbe : Listening... ~n",[self()]),
	receive_loop(Sock,Pid).

receive_loop(Sock,Pid) ->
   receive
       {udp, _Socket, IP, InPortNo, Packet} ->
           io:format("~w~n--From: ~p~n--Port: ~p~n--Data: ~p~n",[self(),IP,InPortNo,Packet]),
	   Pid ! {stickynode,IP,Packet},
           receive_loop(Sock,Pid);
       stop -> true;
       AnythingElse -> io:format("RECEIVED: ~p~n",[AnythingElse]),
           receive_loop(Sock,Pid)
   end.

caster(Sock,RIp) ->
	io:fwrite("~w StickyProbe : Casting... ~n",[self()]),
   	%%{ok,IP} = inet_parse:address(?STICKY_PROBE_IP),
	ok = gen_udp:send(Sock,RIp,?STICKY_PROBE_PORT,<<"sticky">>),
	receive
		stop -> ok
	after 1000 ->
		caster(Sock,RIp)
	end.




