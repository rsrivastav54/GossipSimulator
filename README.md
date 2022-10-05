# GossipSimulator

```
1. Master
        Based on the algorithm, it starts the specific nodes,
        and simultaneously creates the Index to Pid map.
        It then waits for any nodes who wants to know the Pid.
2. Push Sum Node / Gossip Node
        The master starts one of the node. It then calls the
        neighbor module to get the neighbors. Then it selects
        one of the neighbor. It then asks the Master for the
        Pid, then sends the messsage to neighbor and waits for
        any neihbor to send a message to it.
3. Neighbor
        Based on the index and Topology creats the list of nighbors.
```

c(server). <br />
c(client). <br />
Server = server:start(). <br />
client:set_value(Server, "0"). // populate map <br />
client:get_size(Server). // get the size of the map <br />
client:get_value(Server, "0") // return pid of the client with index 0 <br />
