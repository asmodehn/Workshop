-module(sn_probe_LAN).
-export([init/1,fin/1,open/2,close/1,getlocalif/1,receiver/3,caster/2]).

%%including selftest header
-include("sn_probe.hrl").

%%
%% This module is a StickyNet_Probe implementation in erlang.
%% It advertise itself upon initialization, and can detect other StickyNet nodes.
%% When other nodes are detected, it informs its parent process.
%% It is used to gather nodes statistics in order for the sn_route process to use them
%% to optimise the routes.
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
	PidR = spawn(?MODULE,receiver,[Sock,Pid,Broadcast]),
   	ok = gen_udp:controlling_process(Sock,PidR),
	PidC = spawn(?MODULE,caster,[Sock,Broadcast]),
	{Sock,PidR,PidC}.
	%%Calling process must then wait and receive message

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

receiver(Sock,Pid,RIp) ->
	io:fwrite("~w StickyNet_Probe : Listening... ~n",[self()]),
	receive_loop(Sock,Pid,RIp).

receive_loop(Sock,Pid,RIp) ->
   receive
       {udp, _Socket, IP, InPortNo, Packet} ->
	Data = binary_to_term(Packet),
           io:format("~w~n--From: ~p~n--Port: ~p~n--Data: ~p~n",[self(),IP,InPortNo,Data]),
	% if ttl >0 we resend
	case Data#probe_msg.ttl>0 of
		true ->
	ok = gen_udp:send(Sock,RIp,?STICKY_PROBE_PORT,term_to_binary(Data#probe_msg{ttl= Data#probe_msg.ttl - 1}));
		false -> ok
	end,

	% we transmit to the main program

	   Pid ! {stickynode,IP,Data},
           receive_loop(Sock,Pid,RIp);
       stop -> true;
       AnythingElse -> io:format("RECEIVED: ~p~n",[AnythingElse]),
           receive_loop(Sock,Pid,RIp)
   end.

caster(Sock,RIp) ->
	io:fwrite("~w StickyProbe : Casting... ~n",[self()]),
   	%%{ok,IP} = inet_parse:address(?STICKY_PROBE_IP),
	ok = gen_udp:send(Sock,RIp,?STICKY_PROBE_PORT,term_to_binary(#probe_msg{nid="stickynode"})),
	receive
		stop -> ok
	after 5000 ->
		timeout
	end.




