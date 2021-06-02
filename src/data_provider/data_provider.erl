-module(data_provider).

-callback get(Key :: term()) -> {ok, Data :: binary()} | {error, Error :: term()}.
