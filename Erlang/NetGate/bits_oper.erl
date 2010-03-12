-module(bits_oper).

-author('Alexandre VINCENT <alex@asmodehn.com>').

% this modules redefine bitwise operators for bitstream, instead of only on 8 bits by default

-export([bs_reverse/1,bs_not/1]).
-export([bs_true/1,bs_false/1,bs_random/1]).
-export([bs_and/2,bs_or/2,bs_xor/2,bs_sl/2,bs_sr/2]).
-export([bs_show/1,bs_autotest/1,bs_oper_boolalg_test/2,bs_oper_boolsimplif_test/3]).

%%existing bitstring operators : 
%%Signature                                                Definition
%%bit size/1::bitstring() -> integer()                     Returns the size of a bit string in bits.
%%                                                         This BIF is allowed in guards.
%%list to bitstring/1::bitstring list() -> bitstring()     Concatenates the bit strings and chars in the bitstring list to
%%                                                         create a bit string. A bitstring list is an io list which can contain
%%                                                         bit strings as well as binaries the chars in the bitstring list are treated
%%                                                         as if they were bit strings consisting of 8 bits.
%%bitstring to list/1::bitstring() -> [char()|bitstring()] Turns a bit string into a list of characters and if the number of bits
%%                                                         in the bit string is not evenly divisible by eight the last element
%%                                                         in the list is a bit string consisting of the last 1-7 bits of the original
%%                                                         bit string.
%%is bitstring/1::any() -> bool()                          Returns true if the argument is a bit string, otherwise it returns false.
%%                                                         This BIF is allowed in guards.
%%

% reverse a bitstring, bit by bit
bs_reverse(<<I:1,B/bits>> ) -> << ( bs_reverse(B))/bits,I:1 >>;
bs_reverse(<<>>) -> <<>>.

%TODO :improve performance and code design... same with bitwise comprehension if possible ? or more arithmetic ?
% unary bitwise not
bs_not(<<I:1/bits,B/bits>>) when I == <<0:1>> -> <<1:1,(bs_not(B))/bits >>;
bs_not(<<I:1/bits,B/bits>>) when I == <<1:1>> -> <<0:1,(bs_not(B))/bits >>;
bs_not(<<>>) -> <<>>.

%to make sure we have same size when we have 2 operands
bs_padding(Func,<<B/bits>>,<<C/bits>>) when bit_size(B) > bit_size(C) -> bs_padding(Func,<<B/bits>>,<<0:1,C/bits>>);
bs_padding(Func,<<B/bits>>,<<C/bits>>) when bit_size(B) < bit_size(C) -> bs_padding(Func,<<0:1,B/bits>>,<<C/bits>>);
bs_padding(Func,<<B/bits>>,<<C/bits>>) when bit_size(B) == bit_size(C) -> Func(<<B/bits>>,<<C/bits>>).

% bitwise and
%padding if needed to match longer bitstring
bs_and(<<B/bits>>,<<C/bits>>) when bit_size(B) /= bit_size(C) -> bs_padding(bs_and, <<B/bits>>,<<C/bits>>);
bs_and(<<I:1/bits,B/bits>>,<<J:1/bits,C/bits>>) when bit_size(B) == bit_size(C), I == <<1:1>> -> <<J:1/bits,(bs_and(B,C))/bits>>;
bs_and(<<I:1/bits,B/bits>>,<<_:1/bits,C/bits>>) when bit_size(B) == bit_size(C), I == <<0:1>> -> <<0:1,(bs_and(B,C))/bits>>;
bs_and(<<>>,<<>>) -> <<>>.

% bitwise or 
bs_or(<<B/bits>>,<<C/bits>>) when bit_size(B) /= bit_size(C) -> bs_padding(bs_or, <<B/bits>>,<<C/bits>>);
bs_or(<<I:1/bits,B/bits>>,<<J:1/bits,C/bits>>) when I == <<0:1>> -> <<J:1/bits,(bs_or(B,C))/bits>>;
bs_or(<<I:1/bits,B/bits>>,<<_:1/bits,C/bits>>) when I == <<1:1>> -> <<1:1,(bs_or(B,C))/bits>>;
bs_or(<<>>,<<>>) -> <<>>.

% arithmetic bitwise xor
bs_xor(<<B/bits>>,<<C/bits>>) when bit_size(B) /= bit_size(C) -> bs_padding(bs_xor, <<B/bits>>,<<C/bits>>);
bs_xor(<<I:1/bits,B/bits>>,<<J:1/bits,C/bits>>) when I == <<0:1>> -> << J:1/bits , (bs_xor(B,C))/bits >>;
bs_xor(<<I:1/bits,B/bits>>,<<J:1/bits,C/bits>>) when I == <<1:1>> -> << (bs_not(J)):1/bits , (bs_xor(B,C))/bits >>;
bs_xor(<<>>,<<>>) -> <<>>.

% arithmetic bitshift left
bs_sl(<<_:1/bits,B/bits>>,N) when N > 0 -> bs_sl(<<B/bits,0:1>>,N-1);
bs_sl(<<>>,N) when N > 0 -> bs_sl(<<0:1>>,N-1);
bs_sl(<<B/bits>>,N) when N == 0 -> <<B/bits>>;
bs_sl(<<B/bits>>,N) when N < 0 -> bs_sr(<<B/bits>>, -1 * N).


% bitshift right
bs_sr(<<B/bits>>,N) when N >= 0 -> bs_reverse(bs_sl(bs_reverse(<<B/bits>>),N));
%WRONG
%bs_sr(<<I:1/bits,B/bits>>,N) when N < (bit_size(B)+1) -> bs_sr(<<0:1,I:1,B/bits>>,N-1);
%bs_sr(<<B/bits>>,N) when N >= (bit_size(B)) -> <<0:(bit_size(B))>>;
bs_sr(<<B/bits>>,N) when N < 0 -> bs_sl(<<B/bits>>, -1 * N).


% display
bs_show(<<B/bits>>) -> io:fwrite("~s~n",[bs_to_string(B)]).

bs_to_string(<<B/bits>>) -> bs_to_string(<<B/bits>>,"").
bs_to_string(<<I:1/bits,B/bits>>,String) when I== <<1:1>> -> bs_to_string(B,String ++ "X");
bs_to_string(<<I:1/bits,B/bits>>,String) when I== <<0:1>> -> bs_to_string(B,String ++ "_");
bs_to_string(<<>>,String) -> String++"".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%selftest on a given bitstring
bs_autotest(Nb) when Nb == 0 -> ok;
bs_autotest(Nb) -> 
	random:seed(now()),
	%generate random int
	Num=random:uniform((1 bsl 8) -1), % to get maximum integer for equivalent conversion to bits
	ok = bs_oper_boolalg_test(Num,<<Num:8>>),
	ok = bs_oper_boolsimplif_test(bs_random(128),bs_random(128),bs_random(128)),
	ok = bs_autotest(Nb-1).

%generate random Bitstring
bs_random(Size) when Size > 8 -> << (random:uniform(255)):8 , (bs_random(Size-8))/bits >>;
bs_random(Size) when Size =< 8 -> << (random:uniform(255)):Size >>.
bs_true(Size) when Size > 8 -> << 2#11111111:8,(bs_true(Size-8))/bits >>;
bs_true(Size) when Size =< 8 -> << 2#11111111:Size >>.
bs_false(Size) when Size > 8 -> << 0:8,(bs_false(Size-8))/bits >>;
bs_false(Size) when Size =< 8 -> << 0:Size >>.


bs_oper_boolalg_test(Num,Bin) ->
	random:seed(now()),
	io:fwrite("Value : ~w -> ~w~n",[Num,Bin]),
	io:fwrite("| ~8s          ||  ~8s  || ~10s |~n",["Operator","Integer","BitString"]),
	%% equality test
	io:fwrite("| ~8s          ||  ~8.2B  ||  ~8s  |~n",["Id",Num,bs_to_string(Bin)]),
	true = <<Num:8>> == Bin,
	%% not test
	io:fwrite("| ~8s          ||  ~8.2B  ||  ~8s  |~n",["Not",bnot Num,bs_to_string( bs_not(Bin))]),
	true = <<(bnot Num):8>> == bs_not(Bin),
	%% Left Shift
	LS = random:uniform(8),
	io:fwrite("| ~8s ~8B ||  ~8.2B  ||  ~8s  |~n",["LShift",LS,Num bsl LS,bs_to_string( bs_sl(Bin,LS))]),
	true = <<(Num bsl LS):8>> == bs_sl(Bin,LS),
	%% Right Shift
	RS = random:uniform(8),
	io:fwrite("| ~8s ~8B ||  ~8.2B  ||  ~8s  |~n",["RShift",RS,Num bsr RS,bs_to_string( bs_sr(Bin,RS))]),
	true = <<(Num bsr RS):8>> == bs_sr(Bin,RS),
	%% And
	AndOp = random:uniform(255),
	io:fwrite("| ~8s ~8.2B ||  ~8.2B  ||  ~8s  |~n",["And",AndOp,Num band AndOp,bs_to_string( bs_and(Bin,<<AndOp:8>>))]),
	true = <<(Num band AndOp):8>> == bs_and(Bin,<<AndOp:8>>),
	%% Or
	OrOp = random:uniform(255),
	io:fwrite("| ~8s ~8.2B ||  ~8.2B  ||  ~8s  |~n",["Or",OrOp,Num bor OrOp,bs_to_string( bs_or(Bin,<<OrOp:8>>))]),
	true = <<(Num bor OrOp):8>> == bs_or(Bin,<<OrOp:8>>),
	%% Xor	
	XorOp = random:uniform(255),
	io:fwrite("| ~8s ~8.2B ||  ~8.2B  ||  ~8s  |~n",["Xor",XorOp,Num bxor XorOp,bs_to_string( bs_xor(Bin,<<XorOp:8>>))]),
	true = <<(Num bxor XorOp):8>> == bs_xor(Bin,<<XorOp:8>>),

	ok.

bs_oper_boolsimplif_test(<<A/bits>>,<<B/bits>>,<<C/bits>>) ->
	%Idempotent A
	io:fwrite("Idempotent Laws :~n",[]),
	io:fwrite("~12s ~s~n",["A = ",bs_to_string(A)]),
	io:fwrite("~12s ~s~n",["A & A",bs_to_string(bs_and(A,A))]), 
	true = bs_and(A,A) == A,
	io:fwrite("~12s ~s~n",["A | A",bs_to_string(bs_or(A,A))]), 
	true = bs_or(A,A) == A,

	%Idempotent B
	io:fwrite("~12s ~s~n",["B = ",bs_to_string(B)]),
	io:fwrite("~12s ~s~n",["B & B",bs_to_string(bs_and(B,B))]), 
	true = bs_and(B,B) == B,
	io:fwrite("~12s ~s~n",["B | B",bs_to_string(bs_or(B,B))]), 
	true = bs_or(B,B) == B,

	%Idempotent C
	io:fwrite("~12s ~s~n",["C = ",bs_to_string(C)]),
	io:fwrite("~12s ~s~n",["C & C",bs_to_string(bs_and(C,C))]), 
	true = bs_and(C,C) == C,
	io:fwrite("~12s ~s~n",["C | C",bs_to_string(bs_or(C,C))]), 
	true = bs_or(C,C) == C,

	%Associativity
	io:fwrite("Associative Laws :~n",[]),
	io:fwrite("~12s ~s~n",["(A&B)&C",bs_to_string(bs_and(bs_and(A,B),C))]),
	io:fwrite("~12s ~s~n",["A&(B&C)",bs_to_string(bs_and(A,bs_and(B,C)))]), 
	true = bs_and(bs_and(A,B),C) == bs_and(A,bs_and(B,C)),
	io:fwrite("~12s ~s~n",["(A|B)|C",bs_to_string(bs_or(bs_or(A,B),C))]),
	io:fwrite("~12s ~s~n",["A|(B|C)",bs_to_string(bs_or(A,bs_or(B,C)))]), 
	true = bs_or(bs_or(A,B),C) == bs_or(A,bs_or(B,C)),
	
	%Commutativity
	io:fwrite("Commutative Laws :~n",[]),
	io:fwrite("~12s ~s~n",[" A & B ",bs_to_string(bs_and(A,B))]),
	io:fwrite("~12s ~s~n",[" B & A ",bs_to_string(bs_and(B,A))]),
	true = bs_and(A,B) == bs_and(B,A),
	io:fwrite("~12s ~s~n",[" A | B ",bs_to_string(bs_or(A,B))]),
	io:fwrite("~12s ~s~n",[" B | A ",bs_to_string(bs_or(B,A))]),
	true = bs_or(A,B) == bs_or(B,A),


	%Distributivity
	io:fwrite("Distributive Laws :~n",[]),
	io:fwrite("~12s ~s~n",["A&(B|C)",bs_to_string(bs_and(A,bs_or(B,C)))]),
	io:fwrite("~12s ~s~n",["(A&B)|(A&C)",bs_to_string(bs_or(bs_and(A,B),bs_and(A,C)))]),
	true = bs_and(A,bs_or(B,C)) == bs_or(bs_and(A,B),bs_and(A,C)),
	io:fwrite("~12s ~s~n",["A|(B&C)",bs_to_string(bs_or(A,bs_and(B,C)))]),
	io:fwrite("~12s ~s~n",["(A|B)&(A|C)",bs_to_string(bs_and(bs_or(A,B),bs_or(A,C)))]),
	true = bs_or(A,bs_and(B,C)) == bs_and(bs_or(A,B),bs_or(A,C)),
	
	%Identity A
	io:fwrite("Identity Laws :~n",[]),
	io:fwrite("~12s ~s~n",["A = ",bs_to_string(A)]),
	io:fwrite("~12s ~s~n",["A & 1",bs_to_string(bs_and(A,bs_true(bit_size(A))))]),
	true = bs_and(A,bs_true(bit_size(A))) == A,
	io:fwrite("~12s ~s~n",["A | 0",bs_to_string(bs_or(A,bs_false(bit_size(A))))]),
	true = bs_or(A,bs_false(bit_size(A))) == A,
	io:fwrite("~12s ~s~n",["A | 1 = 1",bs_to_string(bs_or(A,bs_true(bit_size(A))))]),
	true = bs_or(A,bs_true(bit_size(A))) == bs_true(bit_size(A)),
	io:fwrite("~12s ~s~n",["A & 0 = 0",bs_to_string(bs_and(A,bs_false(bit_size(A))))]),
	true = bs_and(A,bs_false(bit_size(A))) == bs_false(bit_size(A)),
		
	%Complement Laws
	io:fwrite("Complement Laws :~n",[]),
	io:fwrite("~12s ~s~n",["A&-A=0",bs_to_string(bs_and(A,bs_not(A)))]),
	true = bs_and(A,bs_not(A)) == bs_false(bit_size(A)),
	io:fwrite("~12s ~s~n",["A|-A=1",bs_to_string(bs_or(A,bs_not(A)))]),
	true = bs_or(A,bs_not(A)) == bs_true(bit_size(A)),
	io:fwrite("~12s ~s~n",["-0 = 1", bs_to_string(bs_not(bs_false(bit_size(A))))]),
	true = bs_not(bs_false(bit_size(A))) == bs_true(bit_size(A)),
	io:fwrite("~12s ~s~n",["-1 = 0", bs_to_string(bs_not(bs_true(bit_size(A))))]),
	true = bs_not(bs_true(bit_size(A))) == bs_false(bit_size(A)),

	%Involution
	io:fwrite("Involution Law :~n",[]),
	io:fwrite("~12s ~s~n",["-(-A) = A",bs_to_string(bs_not(bs_not(A)))]),
	true = bs_not(bs_not(A)) == A,

	%De Morgan's Law
	io:fwrite("De Morgan's Law :~n",[]),
	io:fwrite("~12s ~s~n",["-(A&B)",bs_to_string(bs_not(bs_and(A,B)))]),
	io:fwrite("~12s ~s~n",["-A|-B",bs_to_string(bs_or(bs_not(A),bs_not(B)))]),
	true = bs_not(bs_and(A,B)) == bs_or(bs_not(A),bs_not(B)),
	io:fwrite("~12s ~s~n",["-(A|B)",bs_to_string(bs_not(bs_or(A,B)))]),
	io:fwrite("~12s ~s~n",["-A&-B",bs_to_string(bs_and(bs_not(A),bs_not(B)))]),
	true = bs_not(bs_or(A,B)) == bs_and(bs_not(A),bs_not(B)),
	


% Heavy simplification exercize
%#  Simplify: C + BC:
%Expression 	Rule(s) Used
%C + BC 	Original Expression
%C + (B + C) 	DeMorgan's Law.
%(C + C) + B 	Commutative, Associative Laws.
%T + B 	Complement Law.
%T 	Identity Law.

%# Simplify: AB(A + B)(B + B):
%Expression 	Rule(s) Used
%AB(A + B)(B + B) 	Original Expression
%AB(A + B) 	Complement law, Identity law.
%(A + B)(A + B) 	DeMorgan's Law
%A + BB 	Distributive law. This step uses the fact that or distributes over and. It can look a bit strange since addition does not distribute over multiplication.
%A 	Complement, Identity.

%# Simplify: (A + C)(AD + AD) + AC + C:
%Expression 	Rule(s) Used
%(A + C)(AD + AD) + AC + C 	Original Expression
%(A + C)A(D + D) + AC + C 	Distributive.
%(A + C)A + AC + C 	Complement, Identity.
%A((A + C) + C) + C 	Commutative, Distributive.
%A(A + C) + C 	Associative, Idempotent.
%AA + AC + C 	Distributive.
%A + (A + T)C 	Idempotent, Identity, Distributive.
%A + C 	Identity, twice.
%You can also use distribution of or over and starting from A(A+C)+C to reach the same result by another route.

%# Simplify: A(A + B) + (B + AA)(A + B):
%Expression 	Rule(s) Used
%A(A + B) + (B + AA)(A + B) 	Original Expression
%AA + AB + (B + A)A + (B + A)B 	Idempotent (AA to A), then Distributive, used twice.
%AB + (B + A)A + (B + A)B 	Complement, then Identity. (Strictly speaking, we also used the Commutative Law for each of these applications.)
%AB + BA + AA + BB + AB 	Distributive, two places.
%AB + BA + A + AB 	Idempotent (for the A's), then Complement and Identity to remove BB.
%AB + AB + AT + AB 	Commutative, Identity; setting up for the next step.
%AB + A(B + T + B) 	Distributive.
%AB + A 	Identity, twice (depending how you count it).
%A + AB 	Commutative.
%(A + A)(A + B) 	Distributive.
%A + B 	Complement, Identity. 
%
	ok.




