# COP5615_Gossip_Project_Bonus

## Team Members

- Rishabh Srivastav : UFID 7659-9488
- Ashish Sunny Abraham : UFID 6388-7782

## Commands to run the program
- Compile all the .erl files in the zip folder (master, neighbor, topology, gossip_node).
- Run the project by running the command “master:start()” in the erl shell. 
- Enter the number of nodes, for example, 100.
- Choose the type of topology you want to test the code with(1. for Full, 2. for 2D, 3. for Line and 4. for 3D), and select the algorithm (1. for Gossip, 2. for Push-Sum).
- Enter the number of failure nodes, for example, 60.

## Implementation Details
- We implemented a failure mechanism for the gossip protocol that accepts the total number of nodes and the number of failed nodes from the user. On receiving the user-defined number of failed nodes, we create a list with size equivalent to the number of failed nodes. We randomly designate some nodes as failure nodes which do not transmit messages to their neighboring nodes.
- It was observed that with any number of failure nodes, line topology would never converge completely as the nodes have only two neighbors, therefore there would always be a break while transmitting messages due to the presence of faulty nodes.
- While the other topologies like Full, 2D and 3D with a smaller percentage of failure nodes have a higher percentage of achieving convergence since the number of neighbors of each node is more than two and they are not restricted to just left and right adjacent neighbors, as a result the randomness of choosing nodes is high. However, with a higher percentage of failure nodes, even these topologies fail to achieve 100% convergence.

**Remedy:** 
- At the outset we would like to establish that it is almost impossible to achieve complete convergence in line topology because of the obvious reasons that even if one node is a failure node, then communication beyond that node will not be possible.
- For the other 3 topologies, upon experimenting we found that if the percentage of failure nodes is around 30-35% of the total nodes, then convergence is almost always achieved when each node receives the message 10 times. If suppose the percentage of failure nodes was to increase beyond a level (50% and above) where we cannot achieve convergence, then we propose to increase the number of times the message is received to be greater than 10. This will ensure that the nodes stay alive for longer and can communicate more number of times with its neighbors and thus there will be a higher possibility of each neighboring node receiving a message from a specified node.

## Experimental Example
- Upon testing 3D topology with 60 faulty nodes from a total of 100 nodes and making the receiving condition to a limit of 10 rumors (basically the time till a node stays active and can transmit messages), we were able to achieve 93% convergence.
<img width="448" alt="Screen Shot 2022-10-10 at 5 43 35 PM" src="https://user-images.githubusercontent.com/59756917/194956908-57e524f9-f1e5-4a1d-a217-e164e57e65d0.png">

- However, upon increasing the limit to 20 rumors, the algorithm allowed nodes to stay alive and transmit messages for a bit longer which ultimately led to the convergence of remaining nodes.
<img width="449" alt="Screen Shot 2022-10-10 at 5 44 20 PM" src="https://user-images.githubusercontent.com/59756917/194956959-0bd95a0d-823e-4361-8e30-0d2133499799.png">

## Convergence Time Graphs for Gossip Algorithm with Faulty Nodes
- The total number of faulty nodes considered is 30% of the total number of nodes present. The convergence time is also higher than what it was observed without the presence of faulty nodes.

### Full Topology
<img width="1512" alt="Screen Shot 2022-10-10 at 2 43 13 PM" src="https://user-images.githubusercontent.com/59756917/194956612-196ae815-a5f6-4382-9b80-d436f01d295f.png">

### 2D Topology
<img width="1512" alt="Screen Shot 2022-10-10 at 2 44 23 PM" src="https://user-images.githubusercontent.com/59756917/194956627-cc71eeba-ec81-417a-a07a-77e34d7de061.png">

### 3D Topology
<img width="1512" alt="Screen Shot 2022-10-10 at 2 44 31 PM" src="https://user-images.githubusercontent.com/59756917/194956644-e061b880-9598-48a6-b638-d2bd5ac4f0ae.png">
