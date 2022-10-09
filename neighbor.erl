-module(neighbor).
-export([start/3]).
-export([get_neighbor_list/4]).

get_row_len(S, N) ->
    if (S*S == N) ->
        S;
    true ->
        get_row_len(S+1, N)
    end.

add_random(Index, NodeCount, List) ->
    RandomIndex = (rand:uniform(NodeCount) - 1),
    Check_num = fun(E) -> E == RandomIndex end,
    Status = lists:any(Check_num, List),
    if ((Status== false) and (RandomIndex =/= Index)) -> % check if the new index is present in the list
        RandomList = lists:append([List, [RandomIndex]]),
        RandomList;
    true ->
        add_random(Index, NodeCount, List)
    end.

get_neighbor_list(Index, Topology, NodeCount, List) ->
    shell:strings(false),
    case Topology of
        1 -> % Full Network
            NeighborIndex = (rand:uniform(NodeCount) - 1),
            if (NeighborIndex == Index) ->
                get_neighbor_list(Index, Topology, NodeCount, List);
            true ->
                NewList = lists:append([List, [NeighborIndex]]),
                % io:fwrite(" Full Network Neighbor for ~p : ~w\n", [Index, NewList]),
                NewList
            end;
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
            % io:fwrite(" Line Network Neighbor for ~p : ~w\n", [Index, NewList]),
            NewList;
        _ -> % 2 or 4
            RowLen = get_row_len(1, NodeCount),
            X = (Index div RowLen),
            Y = Index rem RowLen,
            if (Y==0) ->
                LeftNeighbor = [],
                TopLeftNeighbor = [],
                BottomLeftNeighbor = [];
            true ->
                LeftNeighbor = [Index-1],
                if (Index-RowLen-1>=0) ->
                    TopLeftNeighbor = [Index-RowLen-1];
                true ->
                    TopLeftNeighbor = []
                end,
                if (Index+RowLen-1<NodeCount) ->
                    BottomLeftNeighbor = [Index+RowLen-1];
                true ->
                    BottomLeftNeighbor = []
                end
            end,

            if (Y==(RowLen-1)) ->
                RightNeighbor = [],
                TopRightNeighbor = [],
                BottomRightNeighbor = [];
            true ->
                RightNeighbor = [Index+1],
                if (Index-RowLen+1>=0) ->
                    TopRightNeighbor = [Index-RowLen+1];
                true ->
                    TopRightNeighbor = []
                end,
                if (Index+RowLen+1<NodeCount) ->
                    BottomRightNeighbor = [Index+RowLen+1];
                true ->
                    BottomRightNeighbor = []
                end
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
            NewList = lists:append([List, LeftNeighbor, RightNeighbor, TopNeighbor, BottomNeighbor, TopLeftNeighbor, BottomLeftNeighbor, TopRightNeighbor, BottomRightNeighbor]),
            % io:fwrite(" 2d Neighbor for ~p : ~w\n", [Index, NewList]),
            
            if (Topology == 4) ->
                RandomList = add_random(Index, NodeCount, NewList),
                % io:fwrite(" 2d Imperfect Neighbor for ~p : ~w\n", [Index, RandomList]),
                RandomList;
            true -> % Topology == 3
                NewList
            end
    end.

start(Topology, Index, NodeCount) -> % for testing
    get_neighbor_list(Index, Topology, NodeCount, []).
