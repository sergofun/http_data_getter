-module(request_handler).

%% API
-export([init/2]).

-define(DATA_KEY, <<"key">>).

-define(SUCCESS_HTTP_RSP, 200).
-define(REQ_ERROR_HTTP_RSP, 400).
-define(INT_ERROR_HTTP_RSP, 500).
-define(TIMEOUT_HTTP_RSP, 503).

init(Req0, State) ->
  ReturnCode =
    try
      [{?DATA_KEY, Value}] = cowboy_req:parse_qs(Req0),
      {ok, Adapter} = application:get_env(http_data_getter, adapter),
      {ok, _BinData} = Adapter:get(binary_to_list(Value)),
      ?SUCCESS_HTTP_RSP
    catch
        exit:{timeout,{gen_server,call,_}} -> ?TIMEOUT_HTTP_RSP;
        error:{badmatch, _} -> ?REQ_ERROR_HTTP_RSP;
        error:_ -> ?INT_ERROR_HTTP_RSP
    end,
  Req = cowboy_req:reply(ReturnCode, #{
    <<"content-type">> => <<"text/plain">>
  }, <<"">>, Req0),
  {ok, Req, State}.
