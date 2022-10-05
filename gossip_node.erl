-module(gossip_nore).
-export([start/3]).

cur_state(RumorCount, Index, NodeCount, Topology) ->
    receive
        {Rumor} ->
            
            % Get all neighbor
            % Select one neighbor
            % Get Pid of the nieghbor
            % Send message to the neighbor
            % check for exit condition
            cur_state(RumorCount+1, Index, NodeCount, Topology)
            % change 

    end.

start(Index, NodeCount, Topology) ->
    io:fwrite(" Started Gossip Node with pid ~p\n", [self()]),
    cur_state(0, Index, NodeCount, Topology).