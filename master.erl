-module(master).
-export([start/0]).
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

    register(master, self()),

    if
        (Topology == 2) or (Topology == 4) ->
            NewNodeCount = get_perfect_square(1, NodeCount);
    true ->
        NewNodeCount = NodeCount
    end,

    % spawn nodes
    % store the pids in the maps
    % when all the nodes are spawned, start one of the nodes
    % then wait for nodes to ask for the Pids for one of the neighbors
    % spawn(server, loop, [maps:new()]).
    spawn_nodes(0, NewNodeCount, maps:new(), Topology, Algorithm, NewNodeCount),
    unregister(master),
    exit(self(), ok).

spawn_nodes(_, NodeCount, Map, _, _, 0) ->
    StartIndex = (rand:uniform(NodeCount) - 1), % 0 to Nodecount -1
    {ok, StartPid} = maps:find(StartIndex, Map),
    io:fwrite(" The first index ~p and Pid to message is ~p\n", [StartIndex, StartPid]),
    StartPid ! {0, 1}, % may be make it asynchornous
    get_neighbor_pid(Map);

spawn_nodes(Index, NodeCount, Map, Topology, Algorithm, FinalCount) ->
    if (Algorithm == 1) ->
        Pid = spawn(push_sum_node, start, [Index, NodeCount, Topology]);
    true -> % Algorithm == 2
        Pid = spawn(gossip_node, start, [Index, NodeCount, Topology])
    end,
    UpdatedMap = maps:put(Index, Pid, Map),
    spawn_nodes(Index+1, NodeCount, UpdatedMap, Topology, Algorithm, FinalCount-1).

get_neighbor_pid(Map) ->
    receive
        {SenderPid, Index} ->
            {ok, NeighborPid} = maps:find(Index, Map),
            %maybe update the list of nodes who have started sending
            SenderPid ! {NeighborPid},
            get_neighbor_pid(Map)
    end.