## oshinko-get-cluster

This small wrapper takes the name of a cluster and an optional
second argument which is the ip address of an oshinko rest server.
If the second argument is omitted, it will search the environment
for variables of the following form to determine the ip:

    OSHINKO_REST.*SERVER_HOST
    OSHINKO_REST.*SERVER_PORT

If the cluster specified by name already exists in the namespace where
the rest server is running, it will output `exists` on standard out
followed by a newline.

If the cluster specified by name does not already exist in the namespace,
it will output `creating` on standard out followed by a newline.

In either case, the next line will contain the URL of the spark master
for the specified cluster.


## building oshinko-get-gluster

To build oshinko-get-cluster:

    $ make build

The result will be in `_output/oshinko-get-cluster`
