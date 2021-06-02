-module(main_SUITE).

-compile(export_all).

-include_lib("common_test/include/ct.hrl").
-include_lib("proper/include/proper.hrl").
-include_lib("common_test/include/ct_property_test.hrl").

-define(EBIN_PATH, "_build/dev/lib/").

all() -> [client_calls].

suite() ->
  [
    {timetrap, {minutes, 360}}
  ].

init_per_suite(Config) ->
  {ok, ServerNode} = start_server_node(),
  ct_property_test:init_per_suite([{server_node, ServerNode} | Config]).

end_per_suite(Config) ->
  ServerNode = proplists:get_value(server_node, Config),
  ct_slave:stop(ServerNode),
  Config.

%%%================================================================
%%% Test suites
%%%================================================================
client_calls(Config) ->
  ct_property_test:quickcheck(
    client:get_prop(Config),
    Config
  ).

%%%================================================================
%%% Internal functions
%%%================================================================
start_server_node() ->
  ErlFlags =
    "-pa ../../_build/default/lib/*/ebin" ++
    " -config ../../test.config",

  {ok, Node} = ct_slave:start(http_data_getter,
    [
      {kill_if_fail, true},
      {monitor_master, true},
      {boot_timeout, 3},
      {erl_flags, ErlFlags}
    ]),

  pong = net_adm:ping(Node),
  {ok, _} = rpc:call(Node, application, ensure_all_started, [http_data_getter]),

  {ok, Node}.
