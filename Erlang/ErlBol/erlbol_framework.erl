-module(erlbol_framework).
-compile(export_all).

%erlbol:  Erlang + REBOL gui
%website: erlbol.douglasedmunds.com 
%author: Doug Edmunds dae@douglasedmunds.com
%pared-down framework version
%version: 2008.05.12.01

start() ->
  io:format("Module ~p: opening listener~n",[?MODULE]),
  {ok, Listen} = gen_tcp:listen(4321, [binary, {packet, 0},  
					 {reuseaddr, true},
					 {active, true}]),
  spawn(fun() -> par_connect(Listen) end).
    
% run parallel servers (see J. Armstrong book)           
par_connect(Listen) ->           

  io:format("waiting for connection~n"),
  {ok, Socket} = gen_tcp:accept(Listen),     
  io:format("received a connection~n"),
  spawn(fun() -> par_connect(Listen) end),
  io:format("going into socket loop~n"),
  loop(Socket).


loop(Socket) ->
  receive
    {tcp, Socket, Bin} ->
      % from client 
	    io:format("To server (binary) ~p~n",[Bin]),
	    Str = binary_to_term(Bin),  
	    io:format("To server (term)   ~p~n",[Str]),
      % to client
      Reply = erlbol(Str),
	    io:format("From server (term)   ~p~n",[Reply]),
 	    gen_tcp:send(Socket, term_to_binary(Reply)),  
	    loop(Socket);

    {tcp_closed, Socket} ->
	    io:format("Server socket closed~n");
    Otherwise -> 
      io:format("something went wrong ~p~n",[Otherwise])
  end.

% -------------------erlbol/1--------------------
% modify the case statement, but leave "Other -> " last

erlbol(List) ->
   [Head | Tail ] = List,
   Function = list_to_atom(Head),
 
   case Function of
     %samples of using try/catch
     %not needed by erlbol   
     add_ints -> 
        [A , B | _C] = Tail,
        try ?MODULE:Function(list_to_number(A), list_to_number(B)) of
          Val -> Val
        catch
          error:Reason -> Reason 
        end   ;
     add_numbers -> 
        [A , B | _C] = Tail,
        try ?MODULE:Function(list_to_number(A), list_to_number(B)) of
          Val -> Val
        catch
          error:Reason -> Reason 
        end   ;
     Other -> 
        io:format("unknown function: ~p~n", [atom_to_list(Other)]),
        "unknown function: " ++ atom_to_list(Other)  
   end.  

%Utility function for converting a 'string number' to either 
%list_to_integer or list_to_float 

list_to_number(Number) ->
  try list_to_integer( Number) of
    Val_integer -> Val_integer
  catch  
    error:_Why -> try list_to_float(Number) of
                    Val_float -> Val_float
                  catch 
                    error: Reason -> Reason
                  end   
  end.    

% ------------------Sample code -------------------

% samples of clean Erlang functions for erlbol/1
% these can be removed from the code

add_ints(A,B) when is_integer(A), is_integer(B) -> 
  C = A + B,
  io:format("answer: ~p~n",[C]),
  C;
add_ints(_A,_B)  -> 
  C = "Both args must be integers",
  io:format("answer: ~p~n",[C]),
  C.

add_numbers(A,B) -> 
  C = A + B,
  io:format("answer: ~p~n",[C]),
  C.

