-module(test_proc).
-export([runtest/0]).

runtest() ->
	spawn(netproc,start,[])
	spawn(netproc,start,)
