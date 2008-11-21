-module(hangman).
-export([start/0]).
-export([guessword/2]).
-export([guessword/3]).
-export([hideword/2]).

start() -> 
	io:format("~nWelcome to Hangman.~n~n"),
	%TODO improve input
	Life = io:read("Enter the number of life you think need : "),
	guessword({ok,Life},"hangman",[]).
	
guessword({ok,Life},Word,Letters) ->
	io:format(" You have ~w life remaining ~n",[Life] ),
	% todo : exit if Life = 0
	guessword(Word, Letters).
	
guessword(Word,Letters) ->
	hideword(Word,Letters),
	io:format(" Word : ~s ~n",[Word]),
	io:format(" Letters : ~s ~n",[Letters]),
	{ok,I} = io:read("Enter a Letter : "),
	L = atom_to_list(I),
	%TOFIX : if the letter hasnt been guessed yet.
		
	guessword(Word,L ++ Letters ).

%TODO : use eunit to test this part of the code...
hideword ( Word, Letters ) -> hideword( lists:reverse(Word), Letters, [], [] ).

%TOFIX :  when multiple time the same letter, we need to find them ALL.
%TOFIX : when finding letter position 2 should not re-hide letter position 1...

%Letter in Word same as letter guessed
hideword( [L | W] , [L | Wt], Nl , H ) ->
	%io:format("hideword( [L ~w | W ~w] , [L ~w| Wt ~w], Nl ~w , H ~w) ~n ->", [L,W,L,Wt,Nl,H] ),
	hideword ( W , lists:reverse(Nl) ++ [L | Wt] , [] ,[ L | H ] );
	%Letter in word move to hidden word
	
%Letter in Word different than letter guessed	
hideword( [L | W] , [Lt | Wt], Nl , H ) -> 
	%io:format("hideword( [L ~w | W ~w] , [Lt ~w| Wt ~w], Nl ~w, H ~w ) ~n ->", [L,W,Lt,Wt,Nl,H] ),
	hideword ( [L | W] , Wt , [ Lt | Nl ] , H );
	%Letter guessed move to letter backlist
	
%Letter guessed list finished but some letter in word remaining
hideword( [_ | W] , [], Nl , H ) ->
	%io:format("hideword( [_ | W ~w] , [], Nl ~w, H ~w) ~n ->", [W,Nl,H] ),
	hideword ( W , Nl , [], [ $* | H ] );
	%append "*" to word, pass letter in word, and start list of letter again.
	
%Word parsing finished -> display it	
hideword( [], _, _, H ) -> io:format("~s ~n",[H]).
	
	
%	If you need to quickly debug a module in Erlang I have a few easy steps for you (using my Erlang hgsvn module as an example):
%
%1> c(hgsvn, [debug_info]).
%{ok, hgsvn}
%2> ii(hgsvn).
%{module, hgsvn}
%3> ib(hgsvn, start, 0).
%ok
%4> iaa([break]).
%true
%5> hgsvn:start().
%
%After this there is a short pause as the Erlang Debugger is launched. It provides a step-by-step debugging interface and gives the values of all variables in scope. It lets you control the execution of your Erlang program to see where subtle logic errors got in and wrecked things.

%To further explain the commands:

%    * c(hgsvn, [debug_info]). instructs the EShell to compile and reload hgsvn with debug symbols
%    * ii(hgsvn) instructs the Erlang interpreter to load the debug info for the hgsvn module
%    * ib(hgsvn, start, 0) instructs the Erlang interpreter to set a breakpoint on entry to hgsvn:start/0 (ib/2 lets you set line-based breakpoints for cases where they are useful)
%    * iaa([break]) instructs the Erlang interpreter to raise the debugger when it encounters a breakpoint (without this you will have what appears to be an application hang in EShell)
%    * hgsvn:start() invokes the entry-point function for the code I am debugging in this example 

%A big thing to watch out for is the way Step works on nested calls like f(g(X)). When you click Step on code like this it steps into f/1 not into g/1. Bear this in mind and avoid nested calls in code you intend to be able to debug.
