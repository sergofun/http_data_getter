-module(test_adapter).

-behaviour(data_provider).

-export([get/1]).

get("success_read") ->
  {ok, <<>>};

get("long_read") ->
  exit({timeout, {gen_server, call, []}}).