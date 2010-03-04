-module(sn_debug).
-include("sn_debug.hrl").
-export([spawn_debug/3]).
%if possible we should hide this
-export([spawn_wait/4]).

% this is a small include to help debug multiple erlang processes...

%This function spawns a process, along with his trap process, and report
%the PID if the process created
spawn_debug(Module,Func,ArgList) ->
	spawn(?MODULE,spawn_wait,[self(),Module,Func,ArgList]),
	receive
		{'TRANS',TransPid,transok} -> TransPid
	end,
	TransPid.

%TODO : spy messages between processes

%useful for debugging
spawn_wait(PPid,Module,Func,ArgList) ->
	Pid = spawn_link(Module,Func,ArgList),
	process_flag(trap_exit,true),
	PPid ! {'TRANS',Pid,transok},
	io:format("~w:~w(~W) spawned : ~w, Trap set.~n",[Module,Func,ArgList,1,Pid]),
	receive
	%waiting for a message to be displayed on exit
	{'EXIT',FromPid,Reason} ->
	io:format("~w : Exit Signal from ~w. Reason: ~w~n",[self(),FromPid,Reason])
	end,
	ok.
