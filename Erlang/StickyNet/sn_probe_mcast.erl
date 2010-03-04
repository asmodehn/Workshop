-module(stickyprobe_mcast).
-export([init/1,fin/1,open/2,close/1,receiver/2,caster/1]).

%% IPv6 broadcast might be much easier to do than Ipv4 multicast,
%% for the same result...

%% including self-test
-include("stickyprobe.hrl").

%%
%% This module is a StickyProbe implementation in erlang.
%% It can detect other StickyNet nodes, and inform it s parent, usually
%% stickynet.
%% 

%%
%% In Erlang, the API is provided through message passing to the main process
%% the process running start() will act as a message receiver ( for debug purpose ).
%%
%% Run init() in a separate process from the client if you want direct message
%% channel to get notification of detected nodes
%%

%% Initialize StickyProbe to detect other StickyNodes
init(Pid) ->
	io:fwrite("~w StickyProbe : Starting... ~n",[self()]),
	%% autodetection of other nodes
	Sock = open(?STICKY_PROBE_IP,?STICKY_PROBE_PORT),
	PidR = spawn(?MODULE,receiver,[Sock,Pid]),
   	ok = gen_udp:controlling_process(Sock,PidR),
	PidC = spawn(?MODULE,caster,[Sock]),
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

open(Addr,Port) ->
   {ok,IP} = inet_parse:address(Addr),
   {ok,S} = gen_udp:open(Port,[{reuseaddr,true}, {ip,IP}, {multicast_ttl,4}, {multicast_loop,false}, binary]),
   inet:setopts(S,[{add_membership,{Addr,{0,0,0,0}}}]),
   S.

close(S) -> gen_udp:close(S).

receiver(Sock,Pid) ->
	io:fwrite("~w StickyProbe : Listening... ~n",[self()]),
   receive
       {udp, _Socket, IP, InPortNo, Packet} ->
           io:format("~n~nFrom: ~p~nPort: ~p~nData: ~p~n",[IP,InPortNo,inet_dns:decode(Packet)]),
	   Pid ! {stickynode,IP,Packet},
           receiver(Sock,Pid);
       stop -> true;
       AnythingElse -> io:format("RECEIVED: ~p~n",[AnythingElse]),
           receiver(Sock,Pid)
   end.

caster(Sock) ->
	io:fwrite("~w StickyProbe : Casting... ~n",[self()]),
   	{ok,IP} = inet_parse:address(?STICKY_PROBE_IP),
	ok = gen_udp:send(Sock,IP,?STICKY_PROBE_PORT,<<"stickynode">>),
	receive
		stop -> ok
	after 1000 ->
		caster(Sock)
	end.




