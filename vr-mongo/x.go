package main

import (
	"context"
	"fmt"
	"github.com/rwynn/gtm/v2"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/bsontype"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"reflect"
	"time"
)

func main() {
	rb := bson.NewRegistryBuilder()
	//rb.RegisterTypeMapEntry(bsontype.Timestamp, reflect.TypeOf(time.Time{}))
	rb.RegisterTypeMapEntry(bsontype.DateTime, reflect.TypeOf(time.Time{}))
	reg := rb.Build()
	clientOptions := options.Client()
	clientOptions.SetRegistry(reg)
	clientOptions.ApplyURI("mongodb://localhost:27017")
	client, err := mongo.NewClient(clientOptions)
	if err != nil {
		panic(err)
	}
	ctxm, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	err = client.Connect(ctxm)
	if err != nil {
		panic(err)
	}
	defer client.Disconnect(context.Background())
	ctx := gtm.Start(client, &gtm.Options{
		DirectReadNs: []string{"test.test"},
		ChangeStreamNs: []string{"test.test"},
		//MaxWaitSecs: 10,
		OpLogDisabled: true,
	})
	for {
		select {
		case err := <-ctx.ErrC:
			fmt.Printf("got err %+v", err)
			break
		case op := <-ctx.OpC:
			fmt.Printf("got op %+v", op)
			break
		}
	}
}
