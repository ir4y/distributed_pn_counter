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


Cluster configuration
=====================
you nedd to create config file cluster.conf like this
```
{name, master, {0.0.0.0}, 8080}.
{node, 'slave1@server'}.
{node, 'slave2@server'}.
{node, 'slave3@server'}.
{node, 'slave4@server'}.
```    

First line describes the current note.
name is constant atom, then it will be nodename. It will be set with ```net_kernel:start/0``` function call.
Third param is ip addr to bind.
Forth is port to listening.

Other lines is list of cluster nodes names.
Current node will try to connect to each node from list.
If connect will be successed, conection loop will stop.
If no node will be conected, it desn't meter, we start the first node of cluster ;)
