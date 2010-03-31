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

-export([getroot_id/1,give_id/1,give_id/2,give_id/3,takeback_id/2,takeback_id/3,display_id/1]).

% @type id() = bitstring() .

% @doc Create a brand new root ID.
% @doc NbConx is the total number of connexions this node can handle.
% @spec getroot_id() -> {id(),[id()]}
getroot_id(NbConx) -> bits_oper:bs_true(NbConx+1).

%chooses a set of token to be given to the requerant
%give a new ID of 1 token
give_id(<<ID/bits>>) -> give_id(ID,bits_oper:bs_false(bit_size(ID))).
%give a new ID of N token
give_id(<<ID/bits>>,NbTokens) when is_integer(NbTokens) -> give_id(ID,bits_oper:bs_false(bit_size(ID)),NbTokens);
%give one more token ot the client ID
give_id(<<ID/bits>>,<<CID/bits>>) -> give_id(ID,CID,1).
% give any number of token to the client ID
give_id(<<ID/bits>>,<<CID/bits>>,NbTokens) when is_integer(NbTokens)->
	TokenID = get_tokenid(ID,NbTokens),
	NewCID = bits_oper:bs_or(CID,TokenID),
	NewID = bits_oper:bs_and(ID,bits_oper:bs_not(TokenID)),
	%if no token given
	case TokenID == bits_oper:bs_false(bit_size(ID)) of
		false -> {ok,NewID,NewCID};
		true -> {error,NewID,NewCID}%no token given
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
%get back all token
takeback_id(ID,BackID) -> takeback_id(ID,BackID,bits_oper:bs_count_true(BackID)).
%get back any number of token
takeback_id(ID,BackID,NbTok) ->
	TokenID = give_tokenid(BackID,NbTok),
	NewID = bits_oper:bs_or(ID,TokenID),
	NewBackID = bits_oper:bs_and(BackID,bits_oper:bs_not(TokenID)),
	%if no token taken
	case TokenID == bits_oper:bs_false(bit_size(ID)) of
		false -> {ok,NewID,NewBackID};
		true -> {error,NewID,NewBackID}%no token taken
	end.

give_tokenid(<<BackID/bits>>,Nb) when is_integer(Nb), Nb =< 0 ->
	bits_oper:bs_false(bit_size(BackID));
give_tokenid(<<BackID/bits>>,Nb) when is_integer(Nb) ->
	Tok = bits_oper:bs_getfirst_true(<<BackID/bits>>),
	case Tok == BackID of
		false ->
			bits_oper:bs_or(Tok,give_tokenid(bits_oper:bs_and(<<BackID/bits>>,bits_oper:bs_not(Tok)),Nb -1));
		true ->
			BackID
	end.



display_id(ID) ->
	io:fwrite(": ID = ~s~n",[bits_oper:bs_to_string(ID)]).


