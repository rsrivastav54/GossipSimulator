-module(master).
-export([start/0, get_neighbor_pid_gossip/4, get_neighbor_pid_pushsum/4]).
-import(push_sum_node, [start/3]).

get_perfect_square(S, N) ->
    Sq = S*S,
    if (Sq > N) ->
        (S-1)*(S-1);
    true ->
        get_perfect_square(S+1, N)
    end.

start()->
    {ok, NodeCount} = io:read("Number of nodes to start: "),
    {ok, Topology} = io:read("Give a topology from the below options: \n 1: Full Networked \n 2: 2D Grid \n 3: Line \n 4: Imperfect 3D Grid \n"),
    {ok, Algorithm} = io:read("Algorthm from the options: \n 1: Push-Sum \n 2: Gossip \n"),
    Master = self(),
    register(master, self()),

    if
        (Topology == 2) or (Topology == 4) ->
            NewNodeCount = get_perfect_square(1, NodeCount);
    true ->
        NewNodeCount = NodeCount
    end,

    spawn_nodes(0, NewNodeCount, maps:new(), Topology, Algorithm, NewNodeCount, Master).
    %unregister(master),
    %exit(self(), ok).

spawn_nodes(_, NodeCount, Map, _, Algorithm, 0, _) ->
    StartIndex = (rand:uniform(NodeCount) - 1), % 0 to Nodecount -1
    {ok, StartPid} = maps:find(StartIndex, Map),
    MapCount = maps:put(StartIndex, StartPid, maps:new()),
    io:fwrite("Map : ~p\n",[Map]),
    io:fwrite(" The first message to index ~p and Pid ~p\n", [StartIndex, StartPid]),
    if (Algorithm == 1) ->
        StartPid ! {0, 1}; % may be make it asynchornous
    true -> %Algorithm == 2
        StartPid ! {"Oh Yeah!"}
    end,
    if (Algorithm == 1) ->
        {Time, _} = timer:tc(master, get_neighbor_pid_pushsum, [Map, MapCount, 1, NodeCount]);
    true ->
        {Time, _} = timer:tc(master, get_neighbor_pid_gossip, [Map, MapCount, 1, NodeCount])
    end,
    io:fwrite("Total time : ~p\n",[Time]),
    unregister(master),
    exit(self(), ok);

spawn_nodes(Index, NodeCount, Map, Topology, Algorithm, FinalCount, Master) ->
    if (Algorithm == 1) ->
        Pid = spawn(push_sum_node, start, [Index, NodeCount, Topology, Master]);
    true -> % Algorithm == 2
        Pid = spawn(gossip_node, start, [Index, NodeCount, Topology, Master])
    end,
    UpdatedMap = maps:put(Index, Pid, Map),
    spawn_nodes(Index+1, NodeCount, UpdatedMap, Topology, Algorithm, FinalCount-1, Master).

get_neighbor_pid_gossip(_, CountMap, NodeCount, NodeCount) ->
    io:fwrite("Final Communicated Map ::: ~p\n Finish Count : ~p Node Count : ~p\n",[CountMap, NodeCount, NodeCount]),
    io:fwrite("Convergence Achieved, Shuting the master ~n");
    %ok;

get_neighbor_pid_gossip(Map, CountMap, FinishCount, NodeCount) ->
    receive
        {SenderPid, Index} ->
            {ok, NeighborPid} = maps:find(Index, Map),
            A = maps:find(Index, CountMap),
            SenderPid ! {NeighborPid},
            if (A =:= {ok,NeighborPid})->
                get_neighbor_pid_gossip(Map, CountMap, FinishCount, NodeCount);
            true ->
                UpdatedMap = maps:put(Index, NeighborPid, CountMap),
                %SenderPid ! {NeighborPid},
                io:fwrite("Communicated Map ::: ~p\n Finish Count : ~p Node Count : ~p\n",[UpdatedMap, FinishCount, NodeCount]),
                get_neighbor_pid_gossip(Map, UpdatedMap, FinishCount+1, NodeCount)
            end
    end.

get_neighbor_pid_pushsum(_, _, NodeCount, NodeCount) ->
    io:fwrite("Finish Count : ~p Node Count : ~p\n",[NodeCount, NodeCount]),
    io:fwrite("Convergence Achieved, Shuting the master ~n");

get_neighbor_pid_pushsum(Map, MapCount, FinishCount, NodeCount) ->
    MapCount,
    receive
        {SenderPid, Index} ->
            {ok, NeighborPid} = maps:find(Index, Map),
            SenderPid ! {NeighborPid},
            get_neighbor_pid_pushsum(Map, MapCount, FinishCount, NodeCount);
        {SenderIndex} ->
            io:fwrite("~p Converge, Finish Count ~p\n", [SenderIndex, FinishCount]),
            get_neighbor_pid_pushsum(Map, MapCount, FinishCount+1, NodeCount),
            SenderIndex
    end.