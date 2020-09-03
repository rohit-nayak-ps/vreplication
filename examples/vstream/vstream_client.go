package main

import (
	"context"
	"fmt"
	"io"
	"log"

	binlogdatapb "vitess.io/vitess/go/vt/proto/binlogdata"
	topodatapb "vitess.io/vitess/go/vt/proto/topodata"
	_ "vitess.io/vitess/go/vt/vtctl/grpcvtctlclient"
	_ "vitess.io/vitess/go/vt/vtgate/grpcvtgateconn"
	"vitess.io/vitess/go/vt/vtgate/vtgateconn"
)

func main() {
	//vstreamCurrent()
	vstreamCopy()
}

func vstreamCurrent() {
	vgtid :=  &binlogdatapb.VGtid{
		ShardGtids: []*binlogdatapb.ShardGtid{{
				Keyspace: "customer",
				Shard:    "-80",
				Gtid:     "current",
	  },{
				Keyspace: "customer",
				Shard:    "80-",
				Gtid:     "current",
		}},
	}
	filter := &binlogdatapb.Filter{
		Rules: []*binlogdatapb.Rule{{
			Match: "/.*/",
		}},
	}
	startVStream(vgtid, filter)
}

func vstreamCopy() {
	vgtid :=  &binlogdatapb.VGtid{
		ShardGtids: []*binlogdatapb.ShardGtid{{
				Keyspace: "customer",
				Shard: "80-",
				Gtid: "",
	  },{
				Keyspace: "customer",
				Shard: "-80",
				Gtid: "",
	  }},
	}
	filter := &binlogdatapb.Filter{
		Rules: []*binlogdatapb.Rule{{
			Match: "/c.*/",
		}},
	}
	startVStream(vgtid, filter)
}

func startVStream(vgtid *binlogdatapb.VGtid, filter *binlogdatapb.Filter) {
	ctx := context.Background()
	conn, err := vtgateconn.Dial(ctx, "localhost:15991")
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()
	reader, err := conn.VStream(ctx, topodatapb.TabletType_MASTER, vgtid, filter)
	for {
		e, err := reader.Recv()
		switch err {
		case nil:
			for i, ev := range e {
				fmt.Printf("%d:%v\n", i, ev)
			}
		case io.EOF:
			fmt.Printf("stream ended\n")
		default:
			fmt.Printf("remote error: %v\n", err)
		}
	}
}
