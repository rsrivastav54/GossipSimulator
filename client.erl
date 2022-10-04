-module(client).
-export([get_value/2,set_value/3,get_size/1]).

get_value(Server, Key) ->
    Server ! {self(), {get, Key}},
    receive
        {Server, {ok, Value}}->
            Value;
        {Server, error}->
           error
    end.

set_value(Server, Key, Value) ->
    Server ! {self(), {set, Key, Value}},
    receive
        {Server, {ok, Key, Value}}->
            ok
    end.

get_size(Server)->
    Server ! {self(), {size}},
    receive
        {Server, {ok, Size}}->
            Size
    end.
