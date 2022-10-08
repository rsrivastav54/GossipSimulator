-module(gossip_node).
-export([start/3]).
-export([send_neighbor/4]).
-import(neighbor, [get_neighbor_list/4]).

loop_neighbor(_, 0, _, _) ->
    ok;
loop_neighbor(NeighborList, ListIndex, ParentIndex, Rumor) ->
    Neighbor = lists:nth(ListIndex, NeighborList),
    master ! {self(), Neighbor},
    receive
        {NeighborPid} ->
            NeighborAlive = is_process_alive(NeighborPid),
            if (NeighborAlive) ->
                % io:fwrite("~p : Recived nightbor ~p from master which is ~p\n", [ParentPid, NeighborPid, NeighborAlive]),
                io:fwrite("~p sending rumor to ~p\n", [ParentIndex, Neighbor]),
                NeighborPid ! {Rumor};
            true ->
                ok
            end
    end.
    % loop_neighbor(NeighborList, ListIndex-1, ParentIndex, Rumor).


send_neighbor(ParentIndex, Topology, NodeCount, Rumor) ->
    NeighborList = get_neighbor_list(ParentIndex, Topology, NodeCount, []),
    RandomNeighborIndex = rand:uniform(length(NeighborList)),
    loop_neighbor(NeighborList, RandomNeighborIndex, ParentIndex, Rumor),
    send_neighbor(ParentIndex, Topology, NodeCount, Rumor).

cur_state(10, Index, _, _, SenderPid) ->
    % io:fwrite("~p has got 10 messages, exiting with message ~p\n", [self(), "Fir se maa chudha"]),
    exit(SenderPid, ok),
    master ! {Index},
    ok;

cur_state(RumorCount, Index, NodeCount, Topology, SenderPid) ->
    receive
        {Rumor} ->
            if (RumorCount == 1) ->
                NewSenderPid = spawn(gossip_node, send_neighbor, [Index, Topology, NodeCount, Rumor]);  % makeing it async
                % exit(SenderPid, ok);
            true ->
                NewSenderPid = SenderPid,
                ok
            end,
            cur_state(RumorCount+1, Index, NodeCount, Topology, NewSenderPid)
    end.

start(Index, NodeCount, Topology) ->
    io:fwrite(" Started Gossip Node with index: ~p\n", [Index]),
    cur_state(1, Index, NodeCount, Topology, self()).