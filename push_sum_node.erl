-module(push_sum_node).
-export([start/3]).

cur_state(Cursum, Curweight, Index, NodeCount, Topology) ->
    receive
        {Sum, Weight} ->
            Newsum = Cursum + Sum,
            Newweight = Curweight + Weight,
            % Get all neighbor
            % Select one neighbor
            % Get Pid of the nieghbor
            % Send message to the neighbor
            % check for exit condition
            cur_state(Newsum, Newweight, Index, NodeCount, Topology)
            % change 

    end.

start(Index, NodeCount, Topology) ->
    io:fwrite(" Started Push-Sum Node with pid ~p\n", [self()]),
    cur_state(Index, 1, Index, NodeCount, Topology).