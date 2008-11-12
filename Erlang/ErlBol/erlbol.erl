-module(erlbol).
-compile(export_all).

%erlbol:  Erlang + REBOL gui
%website: erlbol.douglasedmunds.com 
%author: Doug Edmunds dae@douglasedmunds.com
%version: 2008.05.04.01

% This code spawns multiple listeners, so multiple
%clients can be actively served at the same time.

% It receives a list of strings: the first is the
% function to be called, followed by the parameters.
% It returns a single value (any type).  The client
% program is responsible for converting that binary
% into a type that it can use.

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
      % all messages from client come in this way, so if it fails its will
      % be at the point of binary_to_term/1 	 
	    io:format("To server (binary) ~p~n",[Bin]),
	    Str = binary_to_term(Bin),  
	    io:format("To server (term)   ~p~n",[Str]),
      Reply = erlbol(Str),
	    io:format("From server (term)   ~p~n",[Reply]),
 	    gen_tcp:send(Socket, term_to_binary(Reply)),  
	    loop(Socket);

    {tcp_closed, Socket} ->
	    io:format("Server socket closed~n");
    Otherwise -> 
      io:format("something went wrong ~p~n",[Otherwise])
  end.

% -------------------
% By design:  do all string conversion here, before 
% they go to the functions, so functions appear clean and work with correct data types
% Since conversions can crash, need to incorporate all try/catch coding
% for parameter types.  If Erlang crashes then the other side goes down

% In general each function passes through erlbol/1,
% as a 'case Function of' value


erlbol(List) ->
   [Head | Tail ] = List,
   Function = list_to_atom(Head),
 
   case Function of
     %this version uses a guard in the function
     add_ints -> 
        [A , B | _C] = Tail,
        try ?MODULE:Function(list_to_number(A), list_to_number(B)) of
          Val -> Val
        catch
          error:Reason -> Reason 
        end   ;

     %this version checks each arg before running the function
     add_ints_alt_version1 -> 
        [A , B | _C] = Tail,
        % check each variable sequentially 
        case catch list_to_integer(A) of 
               {'EXIT', Reason} -> handle(Reason);
            Ai ->
               case catch list_to_integer(B) of  
                 {'EXIT', Reason} -> handle(Reason);
                  Bi ->  
                    ?MODULE:Function(Ai, Bi)
               end
        end;
                        
     add_ints_alt_version2 -> 
        [A , B | _C] = Tail,
        try list_to_integer(A) of
            Ai -> try list_to_integer(B) of
                      Bi -> ?MODULE:Function(Ai, Bi) 
                  catch
                      error:ReasonB -> ReasonB
                  end
            catch 
               error:ReasonA -> ReasonA
            end;          
 
     add_numbers -> 
        [A , B | _C] = Tail,
        try ?MODULE:Function(list_to_number(A), list_to_number(B)) of
          Val -> Val
        catch
          error:Reason -> Reason 
        end   ;
     mult_numbers -> 
        [A , B | _C] = Tail,
        try ?MODULE:Function(list_to_number(A), list_to_number(B)) of
          Val -> Val
        catch
          error:Reason -> Reason
        end    ;
     combine_strings -> 
        [A , B | _C] = Tail,
        ?MODULE:Function(A,B);
     make_list -> 
        [A , B | _C] = Tail,
        ?MODULE:Function(A,B);
     make_tuple -> 
        [A , B | _C] = Tail,
        ?MODULE:Function(A,B);
     make_mess ->   
        [A , B | _C] = Tail,
        ?MODULE:Function(A,B);

     Other -> 
        io:format("unknown function: ~p~n", [atom_to_list(Other)]),
        "unknown function: " ++ atom_to_list(Other)  
   end.  

%A function used by add_ints_alt_version2 when error
handle(Reason) -> {B,_} = Reason, B.

%Utility function for converting a 'number' to either int or float
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


% clean Erlang functions that do the work

add_ints(A,B) when is_integer(A), is_integer(B) -> 
  C = A + B,
  io:format("answer: ~p~n",[C]),
  C;
add_ints(_A,_B)  -> 
  C = "Both args must be integers",
  io:format("answer: ~p~n",[C]),
  C.

add_ints_alt_version1(A,B) -> 
  C = A + B,
  io:format("answer: ~p~n",[C]),
  C.

add_ints_alt_version2(A,B) -> 
  C = A + B,
  io:format("answer: ~p~n",[C]),
  C.

add_numbers(A,B) -> 
  C = A + B,
  io:format("answer: ~p~n",[C]),
  C.

mult_numbers(A,B) ->
  C = A * B,
  io:format("answer: ~p~n",[C]),
  C.

combine_strings(A,B) ->
  C = A ++  " " ++ B,
  io:format("answer: ~p~n",[C]),
  C.
  
make_list(A,B) ->
  C = [A, B],
  io:format("answer: ~p~n",[C]),
  C.  

make_tuple(A,B) ->
  C = {A,B},
  io:format("answer: ~p~n",[C]),
  C.  

make_mess(A,B) ->
  C = [A, B, [A, B ],{A, B, [A, B], {A, B}}],
  io:format("answer: ~p~n",[C]),
  C.  

