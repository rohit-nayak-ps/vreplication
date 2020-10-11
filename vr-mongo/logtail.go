package main

import (
	"fmt"
	"github.com/gnokoheat/oplog"
)

func main() {
	var o = &oplog.Options{
		// "mongodb+srv://rohit:96bTn3cwmriT9tU@rohitmongo1.s3zbd.mongodb.net/sample_airbnb?retryWrites=true&w=majority",
		// (e.g. mongodb://username:password@127.0.0.1:27017,127.0.0.1:27018/local?replicaSet=rs01&authSource=admin)
		Addrs:      []string{"127.0.0.1"}, // replicaset host and port
		Username:   "rohit", // admin db username
		Password:   "abc123", // admin db user password
		ReplicaSet: "rs", // replicaset name
		DB:         "test", // tailing target db
		Collection: "inventory", // tailing target collection
		Events:     []string{"insert", "update", "delete"}, // tailing target method
	}

	l := make(chan *[]oplog.Log) // Oplog Channel
	e := make(chan error) // Error Channel
	fmt.Printf("o is %v\n", o)

	// Oplog tailing start !
	go o.Tail(l, e)

	for {
		select {
		case err := <-e:
			fmt.Printf("[Error] %s\n", err)
			return
		case op := <-l:
			// input oplog handling code
			fmt.Printf("[Result] %v\n", op)
			break
		}
	}
}
