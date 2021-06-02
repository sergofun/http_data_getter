%%%-------------------------------------------------------------------
%%% @author sergofun
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. июнь 2021 15:05
%%%-------------------------------------------------------------------
-module(client).

%% API
-export([get_prop/1]).
-export([do_call/1]).
-export([
  initial_state/0,
  command/1,
  precondition/2,
  next_state/3,
  postcondition/3
]).

-behaviour(proper_statem).

-include_lib("proper/include/proper.hrl").

-define(SUCCESS_QS, "?key=success_read").
-define(LONGREAD_QS, "?key=long_read").
-define(WRONG_QS, "?wrong_key=sample").

get_prop(Config) ->
  numtests(100,
    ?FORALL(Cmds, parallel_commands(?MODULE, []),
      begin
        RunResult = run_parallel_commands(?MODULE, Cmds),
        ct_property_test:present_result(?MODULE, Cmds, RunResult, Config)
      end)
  ).

initial_state() -> [].

precondition(_, _) -> true.

command(_) ->
  Qs = noshrink(
    oneof(
      [
        ?SUCCESS_QS,
        ?LONGREAD_QS,
        ?WRONG_QS
      ])
  ),

  noshrink({call, ?MODULE, do_call, [Qs]}).

next_state(State, _Var, _Call) -> State.

postcondition(_State, {call, client, do_call, [?SUCCESS_QS]}, 200) ->
  true;

postcondition(_State, {call, client, do_call, [?LONGREAD_QS]}, 503) ->
  true;

postcondition(_State, {call, client, do_call, [?WRONG_QS]}, 400) ->
  true;

postcondition(_State, {call, client, do_call, _}, _) ->
  false.


do_call(Qs) ->
  inets:start(),
  {ok, {{"HTTP/1.1", RspCode, _}, _, _}} = httpc:request(get, {"http://localhost:8080" ++ Qs, []}, [], []),
  RspCode.
