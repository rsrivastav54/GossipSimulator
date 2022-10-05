-module(neighbor).
-export([start/3]).

get_row_len(S, N) ->
    if (S*S == N) ->
        S;
    true ->
        get_row_len(S+1, N)
    end.

add_random(NodeCount, List) ->
    RandomIndex = (rand:uniform(NodeCount) - 1),
    Check_num = fun(E) -> E == RandomIndex end,
    Status = lists:any(Check_num, List),
    if (Status== false) -> % check if the new index is present in the list
        RandomList = lists:append([List, [RandomIndex]]),
        RandomList;
    true ->
        add_random(NodeCount, List)
    end.

get_neighbor_list(Index, Topology, NodeCount, List) ->
    case Topology of
        1 -> % Full Network
            NeighborIndex = (rand:uniform(NodeCount) - 1),
            NewList = lists:append([List, [NeighborIndex]]),
            io:fwrite(" Full Network Neighbor for ~p : ~p\n", [Index, NewList]),
            NewList;
        3 -> % Line
            if (Index == 0) ->
                LeftNeighbor = [];
            true ->
                LeftNeighbor = [Index -1]
            end,

            if (Index == (NodeCount-1)) ->
                RightNeighbor = [];
            true ->
                RightNeighbor = [Index +1]
            end,
            % Bug: for 10, 11 it gives random output
            NewList = lists:append([List, LeftNeighbor, RightNeighbor]),
            io:fwrite(" Full Network Neighbor for ~p : ~p\n", [Index, NewList]),
            NewList;
        _ -> % 2 or 4
            RowLen = get_row_len(1, NodeCount),
            X = (Index div RowLen),
            Y = Index rem RowLen,
            if (Y==0) ->
                LeftNeighbor = [];
            true ->
                LeftNeighbor = [Index-1]
            end,

            if (Y==(RowLen-1)) ->
                RightNeighbor = [];
            true ->
                RightNeighbor = [Index+1]
            end,
            
            if (X==0) ->
                TopNeighbor = [];
            true ->
                TopNeighbor = [Index-RowLen]
            end,

            if (X==(RowLen-1)) ->
                BottomNeighbor = [];
            true ->
                BottomNeighbor = [Index+RowLen]
            end,

            % Bug: Somhow giving wrong output for Index = 12 and NodeCount = 16. Correct for all other
            NewList = lists:append([List, LeftNeighbor, RightNeighbor, TopNeighbor, BottomNeighbor]),
            io:fwrite(" 2d Neighbor for ~p : ~p\n", [Index, NewList]),
            
            if (Topology == 4) ->
                RandomList = add_random(NodeCount, NewList),
                io:fwrite(" 2d Imperfect Neighbor for ~p : ~p\n", [Index, RandomList]),
                RandomList;
            true -> % Topology == 3
                NewList
            end


        
        
    end.

start(Topology, Index, NodeCount) -> % for testing
    get_neighbor_list(Index, Topology, NodeCount, []).