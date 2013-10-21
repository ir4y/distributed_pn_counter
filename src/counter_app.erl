-module(counter_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([
                {'_', [{"/counter", counter_handler, []}]}
                ]),
    Ip = {0, 0, 0, 0},
    Port = 8080,
    {ok, _} = cowboy:start_http(
            http, 100, [{ip, Ip}, {port, Port}], [{env, [{dispatch, Dispatch}]}]),
    counter_srv:start_link(),
    counter_sup:start_link().

stop(_State) ->
    ok.
