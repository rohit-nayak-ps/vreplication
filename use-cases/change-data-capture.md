# Streaming data from Vitess for Change Data Capture

The VStream API can be used to stream events from your database cluster. We will
go through an example of using VStream API. A more detailed reference is available
at [VStream API Internals](../internals/vstream-api.md)

The VStream API is accessible over grpc. Our example is in golang.

We will reuse the local example to create a Vitess cluster from which to
stream from.

From the vitess root directory run test/local_example.sh _after_ commenting
out the last line in the script that tears down the installation.

TBD
