-module(counter_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    %% TODO move Ip and Port to _StartArgs
    {ok, [{name, _NodeName, Ip, Port}|_Nodes]} = file:consult("cluster.conf"),
    Dispatch = cowboy_router:compile([
                {'_', [{"/counter", counter_handler, []}]}
                ]),
    {ok, _} = cowboy:start_http(
            http, 100, [{ip, Ip}, {port, Port}], [{env, [{dispatch, Dispatch}]}]),
    counter_srv:start_link(),
    counter_sup:start_link().

stop(_State) ->
    ok.
