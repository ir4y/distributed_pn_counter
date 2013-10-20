-module(counter_srv).
-behaviour(gen_server).
-define(SERVER, ?MODULE).

%% ------------------------------------------------------------------
%% API Function Exports
%% ------------------------------------------------------------------

-export([start_link/0, 
         increment/0, increment/1, 
         decrement/0, decrement/1,
         value/0, merge/1]).

%% ------------------------------------------------------------------
%% gen_server Function Exports
%% ------------------------------------------------------------------

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

%% ------------------------------------------------------------------
%% API Function Definitions
%% ------------------------------------------------------------------

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

increment() ->
    increment(1).
increment(Amount) when is_integer(Amount), Amount > 0 ->
    gen_server:cast(?SERVER, {increment, Amount}).

decrement() ->
    decrement(1).
decrement(Amount) when is_integer(Amount), Amount > 0 ->
    gen_server:cast(?SERVER, {decrement, Amount}).

value() ->
    gen_server:call(?SERVER, {get_value}).

merge(GCounter) ->
    gen_server:call(?SERVER, {merge, GCounter}).

%% ------------------------------------------------------------------
%% gen_server Function Definitions
%% ------------------------------------------------------------------

init([]) ->
    %TODO load counter from local db
    {ok, riak_dt_gcounter:new()}.

handle_call({get_value}, _From, GCounter) ->
    Positive = lists:sum([Amount || {{Sign, _Node} ,Amount} <- GCounter, Sign =:= p]),
    Negative = lists:sum([Amount || {{Sign, _Node} ,Amount} <- GCounter, Sign =:= n]),
    {reply, Positive - Negative, GCounter};
handle_call({merge, OtherGCounter}, _From, GCounter) ->
    MergedGCounter = riak_dt_gcounter:merge(OtherGCounter, GCounter),
    {reply, MergedGCounter, MergedGCounter};
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast({increment, Amount}, GCounter) ->
    {ok, NewGCounter} = riak_dt_gcounter:update({increment, Amount},
                                                {p, node()},
                                                GCounter),
    {noreply, NewGCounter};
handle_cast({decrement, Amount}, GCounter) ->
    {ok, NewGCounter} = riak_dt_gcounter:update({increment, Amount},
                                      {n, node()},
                                      GCounter),
    {noreply, NewGCounter};
handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    %TODO save counter to local db
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% ------------------------------------------------------------------
%% Internal Function Definitions
%% ------------------------------------------------------------------

