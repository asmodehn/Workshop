-module(stickynet).
-export([start/0,init/1,connect/3,listen/1,listen/2]).
-export([recvloop/1,sendloop/1]).

%%
%% This module is a StickyNet implementation in erlang.
%% It can hook to other StickyNet nodes, and provide an interface to a
%% reliable network that just doesnt go down.
%% StickyNet nodes are protected for intermittent network problems.
%% Your application is always connected to other online nodes,
%% unless they have been disconnected for quite a long time already.
%%
%% This is achieved by :
%% - initiating and maintaining connections to multiple peers,
%% - mirroring connections if needed.
%% - if one of your peer goes down, all peers will know it, and advertise it as
%%   unsafe on the network. One can then choose to replace it, in a completely
%%   transparent way for any stickynet client, for the time required by the
%%   failing server.
%% 
%% NO IT trick needed. If your computer stays online most of the time,
%% it IS still on for others ;).
%%
%% Despite increased availability, we believe, good performance can be
%% maintained by :
%% - using faster protocols (stcp,dccp,udp) where appropriate.
%% - using safer protocols (tcp, stcp, dccp) where appropriate.
%%

%%
%% start() will launch a new StickyNet Interface.
%% In Erlang the API is provided through message passing to the process
%%
start() ->
	stickydebug:spawn_debug(stickynet,init,[self()]).

%% Initialize StickyNet for communication with local client Pid process
init(Pid) ->
	io:fwrite("~w StickyNet : Starting... ~n",[self()]),
	c:l(stickyprobe_LAN),
	c:l(stickydebug),
	api_start().


%%Supervisor, with message API.
%%API mandatory for start
api_start() ->
	%waiting to have proper connection to other peers	
	receive
		%Actually initialize stickynet, turning the current machine into a "stickynode"
		{stickynet,'INIT',IP,Opt} ->
			%open connection to other peers connections.
			stickydebug:spawn_debug(stickynet,listen,[Pid,2611]),

			%% autodetection of other nodes
			PPid = stickydebug:spawn_debug(?MODULE,probeget,[self()]),
			stickydebug:spawn_debug(stickyprobe_LAN,init,[PPid]),
			api_main();

		%Turning off stickynet, even before initialization
		{stickynet,'EXIT'} -> ok;
		Y -> io:fwrite("Got X = ~w~n",[Y])
			api_start()
	end.

%% main API during process execution
api_main() ->
%% TODO : client facing API depends in the end of features implemented
		{stickynet,'EXIT'} -> ok;

		Y -> io:fwrite("Got X = ~w~n",[Y])
			api_main();
	end.

probeget(PPid) ->
	%receiving Radar localisation of peers...
	receive
		{stickyprobe,IP,Data} ->
		case Data of
			<<"sticky">> -> 
			%trying to connect to peers to maintain safety index
			%% connection to other nodes
			PPid ! {stickynet,'CONX',IP,[]}
		end;
		X -> io:fwrite("Got X = ~w~n",[X])
	end,

%%This is the supervisor of workers process, actually implementing sticky distribution algorithms
internal_api() ->
	todo.

connect(Pid,RemoteIP,RemotePort) ->
    io:format("~w NetGate : Connecting to ~w on port ~w~n ",[self(),RemoteIP,RemotePort]),
    {ok,Sock} = gen_tcp:connect(RemoteIP,RemotePort,[{active,false},{send_timeout,5000},{packet,2}]),
    spawn_link(sendloop,[Sock]),
	process_flag(trap_exit,true),
	receive
	%waiting for a message to be displayed on exit
	{'EXIT',FromPid,Reason} ->
		io:format("~w : Exit Signal from ~w. Reason: ~w~n",[self(),FromPid,Reason])
	end,
	gen_tcp:close(Sock).

listen(LPort) ->
	io:fwrite("~w StickyNet : Listening on all IPs:~w~n",[self(),LPort]),
    case gen_tcp:listen(LPort,[{active, false},{packet,2}]) of
        {ok, ListenSock} ->
    		acceptloop(ListenSock),
            {ok, Port} = inet:port(ListenSock),
            Port;
        {error,Reason} ->
            {error,Reason}
    end.

listen(LIP,LPort) ->
	io:fwrite("~w StickyNet : Listening on ~w:~w~n",[self(),LIP,LPort]),
    case gen_tcp:listen(LPort,[{active, false},{packet,2},{ip,LIP}]) of
        {ok, ListenSock} ->
    		acceptloop(ListenSock),
            {ok, Port} = inet:port(ListenSock),
            Port;
        {error,Reason} ->
            {error,Reason}
    end.

acceptloop(ListenSock) ->
    case gen_tcp:accept(ListenSock) of
        {ok,S} ->
            spawn(?MODULE,recvloop,[S]),
            acceptloop(ListenSock);
        Other ->
            io:fwrite("~w StickyNet : accept returned ~w - goodbye!~n",[self(),Other]),
            ok
    end.

recvloop(S) ->
    inet:setopts(S,[{active,once}]),
    receive
        {tcp,S,Data} ->
            Answer = Data, % simple echo server
            gen_tcp:send(S,Answer),
            recvloop(S);
        {tcp_closed,S} ->
            io:fwrite("~w StickyNet : Socket ~w closed ~n",[self(),S]),
            ok
    end.


sendloop(Sock) ->
receive
        {Client, send_data, Binary} ->
            case gen_tcp:send(Sock,Binary) of
                {error, timeout} ->
                    io:format("Send timeout, closing!~n",
                              []),
                    %handle_send_timeout(), % Not implemented here
                    Client ! {self(),{error_sending, timeout}},
                    %% Usually, it's a good idea to give up in case of a 
                    %% send timeout, as you never know how much actually 
                    %% reached the server, maybe only a packet header?!
                    gen_tcp:close(Sock);
                {error, OtherSendError} ->
                    io:format("Some other error on socket (~p), closing",
                              [OtherSendError]),
                    Client ! {self(),{error_sending, OtherSendError}},
                    gen_tcp:close(Sock);
                ok ->
                    Client ! {self(), data_sent},
                    sendloop(Sock)
            end
    end.    


