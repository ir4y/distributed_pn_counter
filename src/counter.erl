-module(counter).

-export([
    start/0,
    stop/0
    ]).

-define(APPS, [crypto, ranch, cowboy, counter]).

%% ===================================================================
%% API functions
%% ===================================================================


start() ->
    ok = ensure_started(?APPS),
    ok = sync:go(),
    {ok, [{name, NodeName}|Nodes]} = file:consult("cluster.conf"),
    net_kernel:start([NodeName, shortnames]),
    connect(Nodes).

stop() ->
    sync:stop(),
    ok = stop_apps(lists:reverse(?APPS)).

%% ===================================================================
%% Internal functions
%% ===================================================================

ensure_started([]) -> ok;
ensure_started([App | Apps]) ->
    case application:start(App) of
        ok -> ensure_started(Apps);
        {error, {already_started, App}} -> ensure_started(Apps)
    end.

stop_apps([]) -> ok;
stop_apps([App | Apps]) ->
    application:stop(App),
    stop_apps(Apps).

connect([]) ->
    ok;
connect([{node, Node}|Nodes])->
    io:format("Connecting to ~p", [Node]),
    case net_kernel:connect_node(Node) of
        true -> io:format(" Ok~n"),
                ok;
        false -> io:format(" Fail~n"),
                 connect(Nodes)
    end.

