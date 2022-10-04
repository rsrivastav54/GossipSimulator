# GossipSimulator

c(server).
c(client).
Server = server:start().
client:set_value(Server, "0", self()).  // populate map
client:get_size(Server). // get the size of the map
client:get_value(Server, "0") // return pid of the client with index 0
