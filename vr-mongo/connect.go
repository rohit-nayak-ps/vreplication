package main

import (
	"context"
	"fmt"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"time"
)

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	client, err := mongo.Connect(ctx, options.Client().ApplyURI(
		"mongodb://test:abc123@127.0.0.1/test?retryWrites=true&w=majority",
	))
	if err != nil {
		fmt.Println(err.Error())
		return
	}
	//fmt.Printf("client %v:%s\n", client, err)

	collection := client.Database("test").Collection("inventory")
	count, err := collection.CountDocuments(ctx, bson.D{{}}, nil)
	if err != nil {
		fmt.Println(err.Error())
		return
	}
	fmt.Printf("#docs %d\n", count)
}
