-module(master).
-export([start/0, get_neighbor_pid/4]).
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
    {ok, Algorithm} = io:read("Algorthm from the options: \n 1: Gossip \n"),
    {ok, FaultyCount} = io:read("Enter the number of faulty nodes: \n"),
    Master = self(),
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
    %FaultyCount = 30,
    FaultyList = faulty_list(NewNodeCount,FaultyCount),
    io:fwrite("Faulty List: ~p\n",[FaultyList]),
    spawn_nodes(0, NewNodeCount, maps:new(), Topology, Algorithm, NewNodeCount, Master, FaultyList).
    %unregister(master),
    %exit(self(), ok).

faulty_list(NodeCount, FaultyCount) ->
    [rand:uniform(NodeCount) - 1 || _ <- lists:seq(1, FaultyCount)].

spawn_nodes(_, NodeCount, Map, _, _, 0, _, _) ->
    StartIndex = (rand:uniform(NodeCount) - 1), % 0 to Nodecount -1
    {ok, StartPid} = maps:find(StartIndex, Map),
    MapCount = maps:put(StartIndex, StartPid, maps:new()),
    io:fwrite("Map : ~p\n",[Map]),
    io:fwrite(" The first message to index ~p and Pid ~p\n", [StartIndex, StartPid]),
    StartPid ! {"Rumor"}, % may be make it asynchornous
    {Time, _} = timer:tc(master, get_neighbor_pid, [Map, MapCount, 1, NodeCount]),
    io:fwrite("Total time : ~p\n",[Time]),
    unregister(master),
    exit(self(), ok);
    %get_neighbor_pid(Map, MapCount, 2, NodeCount);

spawn_nodes(Index, NodeCount, Map, Topology, Algorithm, FinalCount, Master, FaultyList) ->
    Pid = spawn(gossip_node, start, [Index, NodeCount, Topology, Master, FaultyList]),
    UpdatedMap = maps:put(Index, Pid, Map),
    spawn_nodes(Index+1, NodeCount, UpdatedMap, Topology, Algorithm, FinalCount-1, Master, FaultyList).

get_neighbor_pid(_, CountMap, NodeCount, NodeCount) ->
    io:fwrite("Final Communicated Map ::: ~p\n Finish Count : ~p Node Count : ~p\n",[CountMap, NodeCount, NodeCount]),
    io:fwrite("Convergence Achieved, Shuting the master ~n");
    %ok;

get_neighbor_pid(Map, CountMap, FinishCount, NodeCount) ->
    receive
        {SenderPid, Index} ->
            {ok, NeighborPid} = maps:find(Index, Map),
            NeighborAlive = is_process_alive(NeighborPid),
            if (NeighborAlive) ->
                A = maps:find(Index, CountMap),
                SenderPid ! {NeighborPid},
                if (A =:= {ok,NeighborPid})->
                    get_neighbor_pid(Map, CountMap, FinishCount, NodeCount);
                true ->
                    UpdatedMap = maps:put(Index, NeighborPid, CountMap),
                    %SenderPid ! {NeighborPid},
                    io:fwrite("Communicated Map ::: ~p\n Finish Count : ~p Node Count : ~p\n",[UpdatedMap, FinishCount, NodeCount]),
                    get_neighbor_pid(Map, UpdatedMap, FinishCount+1, NodeCount)
                end;
            true->
                get_neighbor_pid(Map, CountMap, FinishCount, NodeCount)
            end    
            % io:fwrite("Master: Neighbor of ~p is ~p\n", [SenderPid, NeighborPid]),
            %maybe update the list of nodes who have started sending
            %SenderPid ! {NeighborPid},
            %get_neighbor_pid(Map, CountMap, FinishCount, NodeCount);
        % {SenderIndex} ->
        %     io:fwrite("~p converged, finishcount: ~p\n", [SenderIndex, FinishCount+1]),
        %     get_neighbor_pid(Map, CountMap, FinishCount+1, NodeCount)
    end.
