%% @copyright Asmodehn's Corp.

%% @author Alexandre VINCENT <alex@asmodehn.com>

%% @doc An dynamic vector clock, based on node IDs, inspired by the interval tree clock.

%% Modified BSD License.

-module(dvclock).

-author('Alexandre VINCENT <alex@asmodehn.com>').

-export([start/1,connect/0,autotest/0]).
-export([incr_clock/1,is_after/2,is_before/2]).

-record(vclock,{id , clock}).

%FOR NOW : simple vector clock.

%when you start, you need to ask an index. it is assumed to be different for each nodes in the distribution
%Indx in [1,8]
start(Indx) when Indx=<8, Indx>0 ->
	#vclock{ id = rec_set_id(Indx,<<>>), clock = <<0,0,0,0,0,0,0,0>>}.%vector clock for first event

rec_set_id(Indx,Id) when Indx < 1 , bit_size(Id) == 8 -> Id;
rec_set_id(Indx,Id) when Indx == 1 -> rec_set_id((Indx-1),<<1:1,Id/bits>>);
rec_set_id(Indx,Id) -> rec_set_id((Indx-1),<<0:1,Id/bits>>).
	
	
%when you connect, you will get the ID given by your server
% and the current clock
connect() ->
	%simulated for now
	random:seed (now()),
	#vclock{ id = <<(random:uniform(255)):8>>, clock = << (random:uniform(255)),(random:uniform(255)), (random:uniform(255)), (random:uniform(255)), (random:uniform(255)), (random:uniform(255)), (random:uniform(255)), (random:uniform(255)) >> }.

%increment the clock
incr_clock(Clock=#vclock{}) ->
	#vclock{id = Clock#vclock.id, clock= rec_incr_clock(Clock#vclock.id, Clock#vclock.clock) }. 

rec_incr_clock(<<>>,<<>> ) ->
	<<>>;
rec_incr_clock(<< H:1, T/bits>>,<<HC:8, TC/bits>> ) ->
	<< (HC + H):8, (rec_incr_clock(<<T/bits>>,<<TC/bits>>))/bits>>.
	
%beware is_after <> ! is_before
%check if Clock1 knows about event at Clock2
is_after(Clock1,Clock2) ->
	rec_is_after(Clock1#vclock.clock,Clock2#vclock.clock).

rec_is_after(<<>>,<<>>) -> true;
rec_is_after(<<HC1:8,TC1/bits>>,<<HC2:8,TC2/bits>>) ->
	( HC1 >= HC2 ) and rec_is_after(<<TC1/bits>>,<<TC2/bits>>).
	
%beware is_before <> ! is_after
%check if Clock 2 knows about event at Clock1
is_before(Clock1,Clock2) ->
	rec_is_before(Clock1#vclock.clock,Clock2#vclock.clock).

rec_is_before(<<>>,<<>>) -> true;
rec_is_before(<<HC1:8,TC1/bits>>,<<HC2:8,TC2/bits>>) ->
	( HC1 =< HC2 ) and rec_is_before(<<TC1/bits>>,<<TC2/bits>>).



autotest() ->
	random:seed(now()),
	VC = start(random:uniform(8)),
	io:format("Clock 1 : ~w~n",[VC]),
	VCinc = autotest_incr(random:uniform(32),VC),
	io:format("Clock 2 : ~w~n",[VCinc]),
	true = is_after(VCinc,VC),
	true = is_before(VC,VCinc),
	ok.
	

autotest_incr(Nb,VC) when Nb == 0 -> VC;
autotest_incr(Nb,VC) -> 
	autotest_incr(Nb-1,incr_clock(VC)).

