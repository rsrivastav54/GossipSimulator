# COP5615_Gossip_Project

## Team Members

- Rishabh Srivastav : UFID 7659-9488
- Ashish Sunny Abraham : UFID 6388-7782

## Outline of the project
- The aim of this project is to implement Gossip and Push-Sum protocols over 4 different kinds of topologies and observe the convergence time performance for each topology uptill 8k nodes (Gossip) and upto 1k nodes (Push-Sum).   

## Commands to run the program
- Compile all the .erl files in the zip folder (master, neighbor, topology, push_sum_node, gossip_node). 
- Run the project by running the command “master:start().” in the erl shell. 
- Enter the number of nodes, for example, 100.
- Choose the type of topology you want to test the code with (1. for Full, 2. for 2D, 3. for Line and 4. for 3D), and then select the algorithm (1. for Gossip, 2. for Push-Sum).

## Implementation Details

### Gossip Algorithm
- In our implementation, we terminate a node(actor) when a node has received the rumor 10 times after which it stops transmitting messages, and terminate the algorithm if all nodes have heard the rumor at least once, i.e the network has achieved convergence. Each time a neighbor sends a rumor(message) to its neighbor, a map updates all the nodes that have heard the rumor thus far. After convergence, the nodes stop transmitting the message to their neighbors. Once the network is converged the total time for convergence is printed out along with the final map of all nodes that received the message.

### Push-Sum Algorithm:
- The Push-Sum algorithm assumes that a node converges if its average ratio (s/w value) does not increase more than 10^-10 during three consecutive rounds of message reception. In our implementation of the algorithm, the program terminates when there are no active neighbors or when about 80% of the nodes have converged. Unlike gossip, the convergence achieved in push sum is not 100%. We record the nodes that have converged, increment the counter which gives an idea about the total number of nodes converged and then we terminate the algorithm based on conditions above.

## What is working?
- We are able to implement line, full, 2D, and 3D topologies in any combination with gossip or push-sum protocol. The convergence in Gossip protocol is achieved when all of the nodes in the network have heard the rumor at least once and each node can receive the rumor a maximum of 10 times. In the Push-Sum algorithm the node converges if its average ratio (s/w value) is lesser than 10^-10 during three consecutive rounds of message reception or if there are no active neighbors available. 

### Topologies tested upon:

1. **Full Network**: Every node is a neighbor to every other node in the network. We pick one random node out of all available nodes to start the message passing, and then a random neighbor of the selected node is chosen to further pass on the rumor. The chain of finding a random neighbor everytime continues till the state of convergence is achieved.

2. **2D Grid**: Here we form a NxN grid based on the number of nodes given by the user. A node in the 2D grid can have at max 8 neighbors to send messages to, (4-up,down,left,right and 4 on the diagonals). To communicate, every node selects a random neighbor and passes on the rumor to it, convergence is achieved when all the nodes have heard the rumor at least once.

3. **Line**: A node can send the rumor to either its left neighbor or its right neighbor, i.e there are 2 neighbors present at max to pass on the rumor to. We’ve implemented this topology in a way that the node can select either the left or the right neighbor at random to continue its propagation towards convergence. For example, Node with index 10 will have 9 as its left neighbor and 11 as its right neighbor.

4. **3D**: This is similar to the 2D grid, apart from the fact that instead of having the 8 neighbors, a random neighbor which is different from the previous 8 is also selected to participate in the message passing.

## Observations(Gossip)
### Running gossip for Full Topology
<img width="630" alt="Screen Shot 2022-10-10 at 5 25 56 PM" src="https://user-images.githubusercontent.com/59756917/194954875-be447d98-c08a-4764-9995-62bcb5f1ff6c.png">

### Running gossip for 2D
<img width="628" alt="Screen Shot 2022-10-10 at 5 27 37 PM" src="https://user-images.githubusercontent.com/59756917/194955007-0cb63f16-e455-45b0-8657-28f25dce60d4.png">

### Running gossip for Line
<img width="628" alt="Screen Shot 2022-10-10 at 5 28 20 PM" src="https://user-images.githubusercontent.com/59756917/194955069-263a2018-bc9a-48ba-8b8d-e14b3b3a1838.png">

### Running gossip for 3D
<img width="628" alt="Screen Shot 2022-10-10 at 5 28 53 PM" src="https://user-images.githubusercontent.com/59756917/194955114-9b79c12c-a660-4a54-a2d4-917f66ffdbc1.png">

### Convergence Time Graphs for Gossip Algorithm
<img width="1512" alt="Screen Shot 2022-10-10 at 1 35 48 PM" src="https://user-images.githubusercontent.com/59756917/194953506-fe216834-44f1-4b19-abc2-1edf3322cbad.png">
<img width="1512" alt="Screen Shot 2022-10-10 at 1 36 04 PM" src="https://user-images.githubusercontent.com/59756917/194953569-e1a3c126-0be2-4012-a327-19af27061d06.png">

## Observations(Push-Sum)
### Running Push-Sum for Full Topology
<img width="386" alt="Screen Shot 2022-10-10 at 5 30 01 PM" src="https://user-images.githubusercontent.com/59756917/194955269-73e5c238-ccaa-4d87-92a6-a11d4ede3fcb.png">

### Running Push-Sum for 2D
<img width="395" alt="Screen Shot 2022-10-10 at 5 30 39 PM" src="https://user-images.githubusercontent.com/59756917/194955315-f3d83c47-d7c6-4b6e-9c6d-fdca8ce03ec4.png">

### Running Push-Sum for Line
<img width="400" alt="Screen Shot 2022-10-10 at 5 31 05 PM" src="https://user-images.githubusercontent.com/59756917/194955364-e44e371e-6f88-4d50-82e2-4fc97786288e.png">

### Running Push-Sum for 3D
<img width="386" alt="Screen Shot 2022-10-10 at 5 31 35 PM" src="https://user-images.githubusercontent.com/59756917/194955423-6f5e19ec-2ece-4346-b8c7-94def2f80648.png">

### Convergence Time Graphs for Push-Sum Algorithm
<img width="1512" alt="Screen Shot 2022-10-10 at 1 35 57 PM" src="https://user-images.githubusercontent.com/59756917/194953533-6f787f82-7c88-42b2-a808-6989ecbca12f.png">
<img width="1512" alt="Screen Shot 2022-10-10 at 1 36 12 PM" src="https://user-images.githubusercontent.com/59756917/194953583-ef7db992-9d00-4682-9125-b1b46f520042.png">


## Interesting Observations
- On observation we found that the convergence times(in ms) for all the above mentioned algorithms increases exponentially as we increase the number of nodes.
- 3D topology was found to be the fastest to converge compared to other topologies since every node has about 9 (8 adjacent + 1 random) neighbors connected, scanning time is less and the probability of receiving messages from other nodes increases drastically.
- Convergence time of Line Topology was found to be the maximum as the number of neighbors of each node are only the 2 adjacent nodes, thus restricting and slowing down the process of message transfer and thereby also increases the chance of failure.
- Full Network and 2D perform very similarly to one another as they have access to either more neighbors (2D) or their neighbors are more separated out and can be picked at random which helps cover all the nodes (Full).
- Both the protocols(Gossip and Push-sum) have shown similar graph results for various topologies, presumably due to the similarity in the process of message sharing. However, the push-sum algorithm takes longer to converge than the gossip algorithm.



<!-- 1. Master
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
client:get_value(Server, "0") // return pid of the client with index 0 <br />-->
