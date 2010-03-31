%% @copyright Asmodehn's Corp.

%% @author Alexandre VINCENT <alex@asmodehn.com>

%% @doc A test module for the Netgate ID algorithm

%% Modified BSD License.

-module(test_node_id).

-author('Alexandre VINCENT <alex@asmodehn.com>').

-export([test_getroot_id/1,test_give_new_id/1,test_incr_id/1,test_takeback_id/1,test_decr_id/1]).
-export([autotest/2]).

-record(idrec,{id = <<>>,id_list = []}).
-export([display_idrec/1]).

test_getroot_id(NbConx) ->
	IDR = #idrec{ id = node_id:getroot_id(NbConx) },
	bits_oper:bs_to_string(IDR#idrec.id),
	IDR.

display_idrec(IDR=#idrec{}) ->
	node_id:display_id(IDR#idrec.id),
	display_listid(IDR#idrec.id_list),
	ok.

display_listid(IDlist) when is_list(IDlist) -> display_listid(IDlist,0).
display_listid([<<ID/bits>>|T], Indx) when is_integer(Indx) ->
	io:fwrite(": ID[~w] = ~s~n",[Indx+1,bits_oper:bs_to_string(ID)]),
	display_listid(T,Indx+1);
display_listid([],Indx) -> 
	io:fwrite(": ~w list members.~n",[Indx]), ok.

%testing incrementing token in an already given ID
test_incr_id(IDR=#idrec{}) when length(IDR#idrec.id_list) == 0 ->
	test_give_new_id(IDR);
test_incr_id(IDR=#idrec{}) ->
	display_idrec(IDR),
	IDAsking = lists:nth(random:uniform(length(IDR#idrec.id_list)),IDR#idrec.id_list),
	NbAsked = random:uniform(bits_oper:bs_count_false(IDAsking)),
	{ Success, NewID, GivenID } = node_id:give_id(IDR#idrec.id,IDAsking,NbAsked),
	io:fwrite("==> ID ~s increased by (~w): ~s~n",[bits_oper:bs_to_string(IDAsking),NbAsked,bits_oper:bs_to_string(GivenID)]),
	case Success==ok of
		true -> io:fwrite("OK");
		false -> io:fwrite("Error")
	end,
	#idrec{id = NewID,id_list=[GivenID|IDR#idrec.id_list -- [IDAsking] ] }.

%testing giving away an ID. not dumb values (=< MyID size) random. But can be refused in many cases.
test_give_new_id(IDR=#idrec{}) ->
	display_idrec(IDR),
	NbAsked = random:uniform(bit_size(IDR#idrec.id)),
	{ Success, NewID, GivenID } = node_id:give_id(IDR#idrec.id,NbAsked),
	case Success == ok of 
		true ->
			io:fwrite("==> Given ID for (~w): ~s~n",[NbAsked,bits_oper:bs_to_string(GivenID)]),
			#idrec{id = NewID,id_list=[GivenID|IDR#idrec.id_list]};
		false ->
			io:fwrite("==> Given ID for (~w): ~s~n",[NbAsked,"--Cancelled--"]),
			IDR
	end.

%removing a part of the tokens of an ID
test_decr_id(IDR=#idrec{}) when length(IDR#idrec.id_list) == 0 ->
	io:fwrite("<== Decrease ID : ~s~n",["Impossible : operation cancelled"]),
	IDR;
test_decr_id(IDR=#idrec{}) ->
	display_idrec(IDR),
	BackID = lists:nth(random:uniform(length(IDR#idrec.id_list)),IDR#idrec.id_list),
	NbToks = random:uniform(bits_oper:bs_count_true(BackID)),
	{Success,NewID,NewBackID} = node_id:takeback_id(IDR#idrec.id,BackID,NbToks),
	io:fwrite("ID ~s decreased by ~w : ~s~n",[bits_oper:bs_to_string(BackID),NbToks,bits_oper:bs_to_string(NewBackID)]),
	case Success == ok of
		true -> io:fwrite("OK");
		false -> io:fwrite("Error")
	end,
	%if new client ID is false, we "disconnect" client
	case NewBackID == bits_oper:bs_false(bit_size(NewID)) of
		true ->	#idrec{id = NewID, id_list = IDR#idrec.id_list -- [BackID] };
		false -> #idrec{id = NewID, id_list = [NewBackID | IDR#idrec.id_list -- [BackID] ] }
	end.

% testing getting an ID back from a client
% finding ID from the list of given addresses for testing purpose
test_takeback_id(IDR=#idrec{}) when length(IDR#idrec.id_list) == 0 ->
	io:fwrite("<== Take ID : ~s~n",["Impossible : operation cancelled"]),
	IDR;
test_takeback_id(IDR=#idrec{}) ->
	display_idrec(IDR),
	BackID = lists:nth(random:uniform(length(IDR#idrec.id_list)),IDR#idrec.id_list),
	{Success,NewID,_} = node_id:takeback_id(IDR#idrec.id,BackID),
	case Success == ok of
	true ->
		io:fwrite("<== Take ID : ~s~n",[bits_oper:bs_to_string(BackID)]),
		#idrec{id = NewID, id_list = IDR#idrec.id_list -- [BackID]};
	false ->
		io:fwrite("<== Take ID : ~s~n",["--ERROR--"]),
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
	case random:uniform(4) of
	1 -> %test give ID
		NewIDR=test_give_new_id(MyIDR),
		autotest(NewIDR,NbTests -1);
	2 -> %test get ID back
		case length(MyIDR#idrec.id_list) == 0 of
			true -> autotest(MyIDR,NbTests); %ignoring useless test case
			false -> NewIDR=test_takeback_id(MyIDR),
				autotest(NewIDR,NbTests -1)
		end;
	3 -> %test incr ID
		case length(MyIDR#idrec.id_list) == 0 of
			true -> autotest(MyIDR,NbTests); %ignoring useless test case
			false ->NewIDR=test_incr_id(MyIDR),
				autotest(NewIDR,NbTests -1)
		end;
	4 -> %test decr ID
		case length(MyIDR#idrec.id_list) == 0 of
			true -> autotest(MyIDR,NbTests); %ignoring useless test case
			false -> NewIDR=test_decr_id(MyIDR),
				autotest(NewIDR,NbTests -1)
		end
	end;

%easyi manual autotest run
autotest(NbClientMax,Nbtests) ->
	random:seed(now()),
	MyIDR = test_getroot_id(NbClientMax),
	autotest(MyIDR,Nbtests).


