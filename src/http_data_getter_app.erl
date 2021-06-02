%%%-------------------------------------------------------------------
%% @doc http_data_getter public API
%% @end
%%%-------------------------------------------------------------------

-module(http_data_getter_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Port = application:get_env(http_data_getter, port, 8080),
    Dispatch = cowboy_router:compile([
        {'_', [{"/", request_handler, []}]}
    ]),
    {ok, _} = cowboy:start_clear(http_listener,
        [{port, Port}],
        #{env => #{dispatch => Dispatch}}
    ),
    http_data_getter_sup:start_link().

stop(_State) ->
    ok.
