-module(push_sum_node).
-export([start/4]).
-export([send_neighbor/8]).
-import(neighbor, [get_neighbor_list/4]).


send_neighbor(_, NodeCount, _, _, _, ParentPid, _, NodeCount) ->
    ParentPid ! {"Abort"};

send_neighbor(ParentIndex, NodeCount, Sum, Weight, Topology, ParentPid, Master, SendCount) ->
    NeighborList = get_neighbor_list(ParentIndex, Topology, NodeCount, []),
    RandomNeighborIndex = rand:uniform(length(NeighborList)),
    Neighbor = lists:nth(RandomNeighborIndex, NeighborList),
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
                % io:fwrite("~p sending rumor to ~p\n", [ParentIndex, Neighbor]),
                NeighborPid ! {Sum/2, Weight/2};
                % ParentPid ! {Sum/2, Weight/2, self()},
                % NewSendCount = 0;
            true ->
                NewSendCount = SendCount+1,
                send_neighbor(ParentIndex, NodeCount, Sum, Weight, Topology, ParentPid, Master, NewSendCount)
            end,
    ParentPid
    end.
    % send_neighbor(ParentIndex, NodeCount, Sum/2, Weight/2, Topology, ParentPid, Master, NewSendCount).

check_convergence(OldRation, NewRatio) ->
    MinDiff = math:pow(10, -10),
    Diff = NewRatio - OldRation,
    if (Diff < 0) ->
        ModDiff = -1.0*Diff;
    true ->
        ModDiff = Diff
    end,
    if (ModDiff < MinDiff) ->
        true;
    true ->
        false
    end.

cur_state(_, _, Index, _, _, _, Master, 3) ->
    % exit(SenderPid, ok),
    Master ! {Index},
    io:fwrite("~p shutting down\n", [Index]);



cur_state(Cursum, Curweight, Index, NodeCount, Topology, SenderPid, Master, ConvergeCount) ->
    receive
        {Sum, Weight} ->
            Newsum = Cursum + Sum,
            Newweight = Curweight + Weight,

            % if (SenderPid == self()) ->
            %     ok;
            % true ->
            %     % io:fwrite("~p Killing process \n", [Index]),
            %     exit(SenderPid, ok)
            % end,
            NewSenderPid = spawn(push_sum_node, send_neighbor, [Index, NodeCount, Newsum, Newweight, Topology, self(), Master, 0]),
            Converged = check_convergence(Cursum/Curweight, Newsum/Newweight),
            if (Converged == true) ->
                % io:fwrite("~p has converged count: ~p\n", [Index, ConvergeCount+1]),
                NewConvergeCount = ConvergeCount+1;
            true ->
                % io:fwrite("~p converge count set to 0: \n", [Index]),
                NewConvergeCount = 0
            end,

            
            cur_state(Newsum/2, Newweight/2, Index, NodeCount, Topology, NewSenderPid, Master, NewConvergeCount);

        {Halfsum, Halfweight, ChildPid} ->
            % io:fwrite("~p Values halved \n", [Index]),
            cur_state(Halfsum, Halfweight, Index, NodeCount, Topology, ChildPid, Master, ConvergeCount);
        {AbortMessage} ->
            io:fwrite("~p has no active neighbors, aborting with message ~p\n", [Index, AbortMessage]),
            cur_state(Cursum, Curweight, Index, NodeCount, Topology, SenderPid, Master, 3)
    end.

start(Index, NodeCount, Topology, Master) ->
    io:fwrite(" Started Push-Sum Node with Index ~p\n", [Index]),
    cur_state(Index, 1, Index, NodeCount, Topology, self(), Master, 0).