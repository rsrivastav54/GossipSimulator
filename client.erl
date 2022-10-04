-module(client).
-export([get_value/2,set_value/2,get_size/1]).

get_value(Server, Key) ->
    Server ! {self(), {get, Key}},
    receive
        {Server, {ok, Value}}->
            Value;
        {Server, error}->
           error
    end.

set_value(Server, Key) ->
    Server ! {self(), {set, Key, self()}},
    receive
        {Server, {ok}}->
            ok
    end.

get_size(Server)->
    Server ! {self(), {size}},
    receive
        {Server, {ok, Size}}->
            Size
    end.
