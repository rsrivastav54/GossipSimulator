-module(server).
-export([start/0,loop/1]).

start()->
    spawn(server, loop, [maps:new()]).

loop(Map)->
    receive
        {Client, {get, Key}} ->
            Client ! {self(), maps:find(Key, Map)},
            loop(Map);
        {Client, {set, Key, Value}} ->
            UpdatedMap = maps:put(Key, Value, Map),
            Client ! {self(), {ok}},
            loop(UpdatedMap);
        {Client, {size}}->
            Client ! {self(),{ok, maps:size(Map)}},
            loop(Map)
    end.
