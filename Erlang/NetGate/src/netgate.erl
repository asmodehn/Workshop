-module(netgate).
-export([start/0,init/1,open/1,commloop/1,findpath/2]).

%%TODO : look for SCTP "load sharing on internet"

%%
%% This module is a NetGate network node prototype.
%% It communicates with other NetGate nodes, reorders the messages it receives
%% and display them to all NetGate process server that previously connected.
%%

%%
%% Terminology :
%% Comparing to usual client/server paradigm, used here for connection only.
%%
%% A NetGate Node ( or "Gate") is internally :
%%  - one server ("Entry") listening on 2 interfaces, "private" and "public",
%%  and,
%%  - N local clients, each related to public interface connections.
%%  - These clients are other Gates only.
%%  - N is called the "safety index" of the Gate.
%%
%%  - M local clients, each related to private interface connections.
%%  - These clients can be any usual application.
%%  - M is called the "utility index" of the Gate.
%%
%% Typically the private interface would be binary API, or synchronous IPC calls
%% and the public interface would be socket, asynchronous calls on the network.
%% We will be using the port 2611 for the public socket to connect to
%%
%% Although this is an erlang implementation, care should be taken not to
%% overload the design with processes, as it will be implemented in C++ as well,
%% therefore not having as much help as here for concurrency.
%% Same goes for variables, we will prefer them fixed size, so it is easier to translate
%% to a lower-level language for implementation.
%%
%% We wish to keep the same design as much as possible, to make understanding of
%% the same software in different languages easier.
%%

%start() will launch a new Gate.
start() ->
	spawn_link(netgate,init,["127.0.0.1"]),
	waitfinish().

waitfinish() ->
	process_flag(trap_exit,true),
	receive
	%waiting for a message to be displayed on exit
	{'EXIT',FromPid,Reason} ->
		io:format("~w : Exit Signal from ~w because ~w~n",[self(),FromPid,Reason]);
	X ->
	    io:format("Got X=~w~n",[X])
	end.

init(RemoteIP) ->
	io:fwrite("~w NetGate : Starting... ~n",[self()]),
	spawn_link(netgate,open,[2611]),
	spawn_link(netgate,findpath,[RemoteIP,2611]),
	waitfinish().

open(LPort) ->
	io:fwrite("~w NetGate : Opening ... ~n",[self()]),
    case gen_tcp:listen(LPort,[{active, false},{packet,2}]) of
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
            spawn(?MODULE,commloop,[S]),
            acceptloop(ListenSock);
        Other ->
            io:fwrite("~w Netgate : accept returned ~w - goodbye!~n",[self(),Other]),
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
            io:format("~w NetGate : Socket ~w closed ~n",[self(),S]),
            ok
    end.

findpath(RemoteIP,RemotePort) ->
    io:format("~w NetGate : Connecting to ~w on port ~w~n ",[self(),RemoteIP,RemotePort]),
    {ok,Sock} = gen_tcp:connect(RemoteIP,RemotePort,[{active,false},{send_timeout,5000},
                                                    {packet,2}]),

    spawn(sendloop,[Sock]),
	
    gen_tcp:close(Sock).

sendloop(Sock) ->
receive
        {Client, send_data, Binary} ->
            case gen_tcp:send(Sock,[Input]) of
                {error, timeout} ->
                    io:format("Send timeout, closing!~n",
                              []),
                    handle_send_timeout(), % Not implemented here
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
                    loop(Sock)
            end
    end.    

%CAREFUL ! The clock should be spawned only once !
ngclock() ->
receive
	{Pid,'IGET',Data} ->
		%TODO check ID for validity
		NGId = Data,
		clock(NGId)
end.

ngclock(NGId) ->
receive
	{Pid,'RECV',[NgClock|Data]} ->
		%TODO check VC for validity
		%spawn(process(Data)).
		ngclock(NGId,NGClock)
end.

ngclock(NGId,NGClock) ->
receive

	{Pid,'IGIV',RemoteIP} ->
		
		%compute NGId
		Pid ! {'ACKID',NGId },
		referee(NGId);

	{Pid,'RECV',NGId} ->
		%compute next VC
		Pid ! {'ACKVC',VC },
		referee();

	{Pid,'SEND',NGId} ->
end.



%% Interfaces to hook onto other display modules
%% io
write_econs(Msg) ->
	res = io:fwrite("~s~n",[Msg]),
	res.

read_econs(Prompt) ->
	{ok,Input} = io:fread(Prompt,"~s"),
	Input.
%% gs


%% wx



