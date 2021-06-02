-module(fs_adapter).

-behaviour(data_provider).
-behaviour(gen_server).

-export([
  init/1,
  handle_continue/2,
  handle_call/3,
  handle_cast/2]).

-export([get/1]).

-record(fs_adapter_state, {file_name, reply}).

get(FileName) ->
  {ok, Timeout} = application:get_env(http_data_getter, data_get_timeout),
  {ok, Pid} = gen_server:start(?MODULE, FileName, []),
  gen_server:call(Pid, get, Timeout).

init(FileName) ->
  {ok, #fs_adapter_state{file_name = FileName}, {continue, do_read}}.

handle_continue(do_read, State = #fs_adapter_state{file_name = FileName}) ->
  Reply = file:read_file(code:priv_dir(http_data_getter) ++ "/" ++ FileName),
  {noreply, State#fs_adapter_state{reply = Reply}}.

handle_call(get, _From, State = #fs_adapter_state{reply = Reply}) ->
  {stop, normal, Reply, State}.

handle_cast(_Request, State) ->
  {noreply, State}.

