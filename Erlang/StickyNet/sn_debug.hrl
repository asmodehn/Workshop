%% this is a small include to help debug multiple erlang processes...
-ifdef(debug).
-define(LOG(X), io:format("{~p,~p}: ~p~n", [?MODULE,?LINE,X])).
-else.
-define(LOG(X), true).
-endif.
% To use :
% erlc -Ddebug m.erl
% or
% 1> c(m, {d, debug}).
% {ok,m}
%
% ?LOG(Arg) will then expand to a call to io:format/2 and provide the user
% with some simple trace output.

