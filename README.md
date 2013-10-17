DISTRIBUTED CRDT PN-Counters Server
======================

Implementation of distributed pn counter server in erlang.   
The server should allow the user to increment or decrement a counter by issuing an HTTP POST request.   
And read the counter by issuing an HTTP GET.   
The service should be runnable on multiple nodes and they should always agree on the counter value.   
In the case of a netsplit where the servers are not able to communicate together,   
the counter will be temporarily incorrect,   
but once the network is restored all operations that occurred during this period should be taken into account,   
you might want to take a look at CRDT PN-Counters)   
