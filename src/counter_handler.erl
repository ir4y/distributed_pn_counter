-module(counter_handler).
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Transport, Req, []) ->
        {ok, Req, undefined}.

wrap_handle_ok(Req, Fun, Amount) ->
    counter_srv:Fun(Amount),
    cowboy_req:reply(200,
                     [{<<"content-type">>,
                       <<"application/json; charset=utf-8">>}],
                     jsx:encode([{<<"statust">>, <<"ok">>}]), 
                     Req).

request(<<"GET">>, Req) ->
        Amount = counter_srv:value(),
        cowboy_req:reply(200,
                         [{<<"content-type">>,
                           <<"application/json; charset=utf-8">>}],
                         jsx:encode([{<<"amount">>, Amount}]), 
                         Req);
request(<<"POST">>, Req) ->
        {ok, PostValue, Req2} = cowboy_req:body_qs(Req),
        [{Json, true}] = PostValue,
        case jsx:decode(Json) of
            [{<<"increment">>, Amount}] when is_integer(Amount) -> 
                wrap_handle_ok(Req2, increment, Amount);
            [{<<"decrement">>, Amount}] when is_integer(Amount) -> 
                wrap_handle_ok(Req2, decrement, Amount);
            _ -> request(error, Req2)
        end;
request(_, Req) ->
        %% Method not allowed.
        cowboy_req:reply(405, Req).

handle(Req, State) ->
        {Method, Req2} = cowboy_req:method(Req),
        {ok, Req3} = request(Method, Req2),
        {ok, Req3, State}.


terminate(_Reason, _Req, _State) ->
        ok.

