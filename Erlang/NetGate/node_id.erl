%% @copyright Asmodehn's Corp.

%% @author Alexandre VINCENT <alex@asmodehn.com>

%% @doc A ID algorithm, inspired by the interval tree clock id.

%% Upon creation the master server has an ID = 11111...11111
%% When a new host wants to join, he will need to ask the number of clients he wishes to server
%% The server he is then trying to connect to will give him a part of his ID, as tokens for clients.
%%   For example Master ID = 11111, Host connect to master and ask to server 2 clients,
%%   He will get Host ID = 00111, while Master ID becomes 11000.
%% Upon disconnection or failure of a client, the Server will merge back the ID of its client, and attempt to replace him on the network.
%% This ensures ID unicity, fault tolerance, and customizable dynamic balance of the connection tree.

%% Modified BSD License.

-module(node_id).

-author('Alexandre VINCENT <alex@asmodehn.com>').

-export([getroot_id/1,give_id/2,takeback_id/2,to_string/1]).

% @type id() = bitstring() .

% @doc Create a brand new root ID.
% @doc NbConx is the total number of connexions this node can handle.
% @spec getroot_id() -> id()
getroot_id(NbConx) -> make_id(NbConx,<<1:1>>).

make_id(Nb,Binary) when Nb == 0 -> Binary; 
make_id(Nb,Binary) -> make_id(Nb-1,<<1:1,Binary/bits>> ).

%chooses a set of token to be given to the requerant
give_id(<<MyID/bits>>,NbTokens) ->
	{{given_id,GivenID},_} = find_token(MyID,NbTokens,<<>>),
	NewID = MyID bxor GivenID,
	{{new_id,NewID},{given_id,GivenID}}.

find_token(<<B:1/bits,T/bits>>,Nb,<<GivenID/bits>>) when Nb == 1 ; B == <<0:1>> -> find_token(T,Nb,<<GivenID/bits,0:1>>);
find_token(<<B:1/bits,T/bits>>,Nb,<<GivenID/bits>>) when B == <<1:1>> -> find_token(T,Nb-1,<<GivenID/bits,1:1>>);
find_token(<<>>,Nb,<<GivenID/bits>>) -> {{given_id,GivenID},{missing,Nb}}.

%merging back unused tokens
takeback_id(<<MyID/bits>>,<<FreeID/bits>>) -> {{my_id,MyID bxor FreeID}}. 

%%displaying bitstring ID
to_string(<<X/bits>>) -> build_string_id(X,"").

build_string_id(<<X:1/bits,T/bits>>,String) when X == <<0:1>> -> build_string_id(T,String ++ "_");
build_string_id(<<X:1/bits,T/bits>>,String) when X == <<1:1>> -> build_string_id(T,String ++ "#");
build_string_id(<<>>,String) -> String.



