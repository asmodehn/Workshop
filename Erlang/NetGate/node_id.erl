%% @copyright Asmodehn's Corp.

%% @author Alexandre VINCENT <alex@asmodehn.com>

%% @doc A ID algorithm, inspired by the interval tree clock id.

%% Upon creation the master server has an ID = 11111...11111
%% When a new host wants to join, he will need to ask the number of clients he wishes to server
%% The server he is then trying to connect to will give him a part of his ID, as tokens for clients.
%%   For example Master ID = 11111, Host connect to master and ask to server 2 clients,
%%   He will get Host ID = 11100, while Master ID becomes 00011.
%% Upon disconnection or failure of a client, the Server will merge back the ID of its client, and attempt to replace him on the network.
%% This ensures ID unicity, fault tolerance, and customizable dynamic balance of the connection tree.

%% Modified BSD License.

-module(node_id).

-author('Alexandre VINCENT <alex@asmodehn.com>').

-export([getroot_id/1,give_id/1,give_id/2,takeback_id/2]).

%% temporary, for test only
-export([test_getroot_id/1,test_give_id/1,test_takeback_id/1]).
-export([autotest/2]).

-record(idrec,{id = <<>>,id_list = []}).
-export([display_idrec/1]).

% @type id() = bitstring() .

% @doc Create a brand new root ID.
% @doc NbConx is the total number of connexions this node can handle.
% @spec getroot_id() -> {id(),[id()]}
getroot_id(NbConx) -> #idrec{id=bits_oper:bs_true(NbConx+1)}.
test_getroot_id(NbConx) -> IDR = getroot_id(NbConx), bits_oper:bs_to_string(IDR#idrec.id), IDR.

%chooses a set of token to be given to the requerant
give_id(IDR=#idrec{}) -> give_id(IDR,1).
give_id(IDR=#idrec{},NbTokens) ->
	TokenID = get_tokenid(IDR#idrec.id,NbTokens),
	NewID = bits_oper:bs_and(IDR#idrec.id,bits_oper:bs_not(TokenID)),
	%if no token given
	case TokenID == bits_oper:bs_false(bit_size(IDR#idrec.id)) of
		false -> {ok,TokenID,IDR#idrec{id=NewID,id_list=[TokenID|IDR#idrec.id_list]}};
		true -> {error,TokenID,IDR}%no token given
	end.

%finds token IDi
%Nb integer, counter of tokens we need.
get_tokenid(<<MyID/bits>>,Nb) when Nb > 0 -> 
	Tok = bits_oper:bs_getfirst_true(<<MyID/bits>>),
	case Tok == MyID of
		false ->
			bits_oper:bs_or(Tok,get_tokenid(bits_oper:bs_and(<<MyID/bits>>,bits_oper:bs_not(Tok)),Nb -1));
		true ->
			bits_oper:bs_false(bit_size(MyID)) %no more available token
	end;
get_tokenid(<<MyID/bits>>,Nb) when Nb =< 0 ->
	bits_oper:bs_false(bit_size(MyID)).

%merging back unused tokens
takeback_id(IDR=#idrec{},IDindx) when is_integer(IDindx), IDindx > 0, IDR#idrec.id_list /= []  ->
	BackID =lists:nth(IDindx, IDR#idrec.id_list), 
	NewID = bits_oper:bs_or(IDR#idrec.id,BackID),
	IDR#idrec{id = NewID,id_list = lists:delete(BackID,IDR#idrec.id_list)};
takeback_id(IDR=#idrec{},IDindx) when is_integer(IDindx), IDindx =< 0; IDR#idrec.id_list == []  ->
	IDR;% ignoring impossible operation
takeback_id(IDR=#idrec{},<<BackID/bits>>) -> 
	case lists:member(<<BackID/bits>>,IDR#idrec.id_list) of
		true ->
			{ok, <<BackID/bits>>, IDR#idrec{id = bits_oper:bs_or(IDR#idrec.id,BackID),id_list = IDR#idrec.id_list -- [<<BackID/bits>>]}};
		false ->
			{error,bits_oper:bs_false(bit_size(<<BackID/bits>>)), IDR}
	end.

display_idrec(IDR=#idrec{}) ->
	io:fwrite(": ID = ~s~n",[bits_oper:bs_to_string(IDR#idrec.id)]),
	display_listid(IDR#idrec.id_list),
	ok.

display_listid(IDlist) when is_list(IDlist) -> display_listid(IDlist,0).
display_listid([<<ID/bits>>|T], Indx) when is_integer(Indx) ->
	io:fwrite(": ID[~w] = ~s~n",[Indx+1,bits_oper:bs_to_string(ID)]),
	display_listid(T,Indx+1);
display_listid([],Indx) -> 
	io:fwrite(": ~w list members.~n",[Indx]), ok.

%testing giving away an ID. not dumb values (=< MyID size) random. But can be refused in many cases.
test_give_id(IDR=#idrec{}) ->
	NbAsked = random:uniform(bit_size(IDR#idrec.id)),
	display_idrec(IDR),
	{ Success, GivenID, NewIDR } = give_id(IDR,NbAsked),
	case Success == ok of 
		true ->
			io:fwrite("==> Given ID for (~w): ~s~n",[NbAsked,bits_oper:bs_to_string(GivenID)]);
		false ->
			io:fwrite("==> Given ID for (~w): ~s~n",[NbAsked,"--Cancelled--"])
	end,
	NewIDR.
	
% testing getting an ID back from a client
% finding ID from the list of given addresses for testing purpose
test_takeback_id(IDR=#idrec{}) when is_list(IDR#idrec.id_list)->
	display_idrec(IDR),
	case length(IDR#idrec.id_list) == 0 of
	false ->
		BackID = lists:nth(random:uniform(length(IDR#idrec.id_list)),IDR#idrec.id_list),
		{Success,TakenID,NewIDR} = takeback_id(IDR,BackID),
		case Success == ok of
		true ->
			io:fwrite("<== Take ID : ~s~n",[bits_oper:bs_to_string(TakenID)]),
			NewIDR;
		false ->
			io:fwrite("<== Take ID : ~s~n",["--Cancelled--"]),
			NewIDR
		end;
	true ->
		io:fwrite("<== Take ID : ~s~n",["Impossible : operation cancelled"]),
		%doing nothing
		IDR
	end.
	

%Automated testing
% Nb is the number maximum of connections possible
% test will finish when all IDs have been given back...

%last finishing step : exit test
autotest(MyIDR=#idrec{},NbTests) when is_integer(NbTests), NbTests =< 0 ->
	display_idrec(MyIDR);

%main autotest function. ID can be given and taken back.
autotest(MyIDR=#idrec{},NbTests) when is_integer(NbTests), NbTests >0 ->
	case random:uniform(2) of
	1 -> %test give ID
		NewIDR=test_give_id(MyIDR),
		autotest(NewIDR,NbTests -1);
	2 -> %test get ID back
		NewIDR=test_takeback_id(MyIDR),
		autotest(NewIDR,NbTests -1)
	end;

%easyi manual autotest run
autotest(NbClientMax,Nbtests) ->
	random:seed(now()),
	MyIDR = getroot_id(NbClientMax),
	autotest(MyIDR,Nbtests).


