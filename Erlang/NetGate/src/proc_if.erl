-module(proc_if).

-author('Alexandre VINCENT <alex@asmodehn.com>').

-export([/0]).

-record(conx,{serv_pid , id=0 }).

%This module provides interface to process communication, using the NetGate protocol for message ordering


%FOR_NOW connection to central server
% So that we only need a vector clock (full peer-to-peer messaging requires matrix clock)
connect(Pid) -> #conx{serv_pid = Pid ,request_id(Pid,0,1)}.
disconnect(ConRec = #conx{}) -> giveup_tok(ConRec#conx.serv_pid,ConRec#conx.id,}.

%connect to another process
request_tok(Pid,Id,NbTok) ->
	Pid ! {'REQ_ID',self(),Id,NbTok}
	receive
		{'GET_ID',NId = #idrec{}} -> NId;
		{'NO_ID',NId = #idrec{}} -> NId
	end.

	

%broadcast message
sendmsg(Msg) ->
	Pid ! {'MSG',self(),Msg}.
	

recvloop() ->
	receive
		{'REQ_ID',Pid,NbTok} -> 
			NId = give_id(
			case 0 == give_d(id,NbTok) of
			true -> {'NO_ID',

%get last message
% each process has a mailbox for received message
getmsg() ->
	receive
	%TODO : reorder, reliability, etc.
		{'MSG',Pid,Msg} -> Msg
	end.


%end communication
giveup_tok(Pid,Id,NbTok)->
	Pid ! {'GUP_ID',Id}
	receive
		{'NO_ID',Id = #idrec{}} -> Id
	end.


