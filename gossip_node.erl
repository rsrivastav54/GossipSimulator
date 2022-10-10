-module(gossip_node).
-export([start/5]).
-export([send_neighbor/5]).
-import(neighbor, [get_neighbor_list/4]).

loop_neighbor(_, 0, _, _, _) ->
    ok;
loop_neighbor(NeighborList, ListIndex, ParentIndex, Rumor, Master) ->
    Neighbor = lists:nth(ListIndex, NeighborList),
    %master ! {self(), Neighbor},
    %io:fwrite("~p\n",[Neighbor]),
    MasterAlive = is_process_alive(Master),
    if(MasterAlive) ->
        master ! {self(), Neighbor};
    true ->
        ok
    end,
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


send_neighbor(ParentIndex, Topology, NodeCount, Rumor, Master) ->
    NeighborList = get_neighbor_list(ParentIndex, Topology, NodeCount, []),
    RandomNeighborIndex = rand:uniform(length(NeighborList)),
    loop_neighbor(NeighborList, RandomNeighborIndex, ParentIndex, Rumor, Master),
    send_neighbor(ParentIndex, Topology, NodeCount, Rumor, Master).

cur_state(10, _, _, _, SenderPid, _) ->
    % io:fwrite("~p has got 10 messages, exiting with message ~p\n", [self(), "Fir se maa chudha"]),
    exit(SenderPid, ok);
    % master ! {Index},
    % ok;

cur_state(RumorCount, Index, NodeCount, Topology, SenderPid, Master) ->
    receive
        {Rumor} ->
            if (RumorCount == 1) ->
                NewSenderPid = spawn(gossip_node, send_neighbor, [Index, Topology, NodeCount, Rumor, Master]);  % makeing it async
                % exit(SenderPid, ok);
            true ->
                NewSenderPid = SenderPid,
                ok
            end,
            cur_state(RumorCount+1, Index, NodeCount, Topology, NewSenderPid, Master)
    end.

start(Index, NodeCount, Topology, Master, FaultyList) ->
    io:fwrite(" Started Gossip Node with index: ~p\n", [Index]),
    Check_num = fun(E) -> E == Index end,
    B = lists:any(Check_num, FaultyList),    
    if(B == true)->
        wait_state();
    true->
        io:fwrite(" Started Gossip Node with index: ~p\n", [Index]),
        cur_state(1, Index, NodeCount, Topology, self(), Master)
    end.

wait_state() ->
    receive
        {A,B,C}->
            io:fwrite("Waiting for ~p ~p ~p",[A,B,C])
    end.
