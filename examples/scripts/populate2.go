package main

import (
	"database/sql"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"github.com/paulbellamy/ratecounter"
	"time"
	"context"
	"compress/zlib"
	"bytes"
	"io"
	"encoding/binary"
)

func main2() {
	ctx := context.Background()
	db, err := sql.Open("mysql", "msandbox:msandbox@tcp(127.0.0.1:19327)/test")
	//fmt.Println("connection opened")
	if err != nil {
		panic(err.Error())
	}
	rows, err := db.QueryContext(ctx, "SELECT val, valz FROM c3")
	if err != nil {
		fmt.Println(err)
	}
	defer rows.Close()
	for rows.Next() {
		var val string
		var valz string
		if err := rows.Scan(&val, &valz); err != nil {
			fmt.Println(err)
		}
		v := []byte(valz)

		l1 := uint32(v[0]) +	uint32(v[1])<<8 + uint32(v[2])<<16 + uint32(v[3])<<24
		b2 := make([]byte, 4)
		binary.LittleEndian.PutUint32(b2, l1)
		//fmt.Printf("%d, %d, %d, %d, %d\n", l1, b2[0], b2[1], b2[2], b2[3])

		v1 := v[4:]
		b := bytes.NewBuffer(v1)
		r, e := zlib.NewReader(b)
		if e != nil {
			fmt.Println(e)
			return
		}
		var o bytes.Buffer
		io.Copy(&o, r)
		//fmt.Printf("%s\n%s\n", val, o.Bytes())

		var in bytes.Buffer;
		w:= zlib.NewWriter(&in)
		if err != nil {
			fmt.Println(err)
			return
		}
		w.Write([]byte(val))
		w.Close()
		fmt.Printf("\n\n%s\n\n%s\n", v, in.Bytes())

		fmt.Printf("%d,%d\n", len(v), 4+len(in.Bytes()))
		//s2 := fmt.Sprintf("%x%x", b2, in.Bytes())
		b3 := append(b2, in.Bytes()...)
		_ = b3
		result, err := db.ExecContext(ctx, "update c3 set valy = ?",b3 	  )
		if err != nil {
			fmt.Println(err)
		}
		_ = result
		//fmt.Println(result)
	}
	if err := rows.Err(); err != nil {
		fmt.Println(err)
	}
	defer db.Close()

}

func PrepareTx(db *sql.DB, qry string) (tx *sql.Tx, s *sql.Stmt, e error) {
	if tx, e = db.Begin(); e != nil {
		return
	}

	if s, e = tx.Prepare(qry); e != nil {
		panic(e.Error())
	}
	return
}

func main() {
	counter := ratecounter.NewRateCounter(1 * time.Second)
	done := false
	var i int64
	//query := "insert into product(sku, description, price) values (?,?,?)"
	//query := "update customer set email = ? where customer_id < 1000"
	query := "insert into customer (customer_id, email) values (?,?)"
	query2 := "insert into x2 (id, id2) values (?,?)"
	//query := "update c10m set x = ? where x is null limit 1" // + floor(10 * rand()) limit 1"
	i = 0
	db, err := sql.Open("mysql", "root@tcp(127.0.0.1:15306)/customer")
	//db, err := sql.Open("mysql", "root@tcp(127.0.0.1:19327)/load1")
	fmt.Println("connection opened")
	if err != nil {
		panic(err.Error())
	}
	defer db.Close()
	now := time.Now().UnixNano()
	_ = now
	tx, stmt, err := PrepareTx(db, query)
	if err != nil {
		panic(err.Error())
	}
	tx2, stmt2, err := PrepareTx(db, query2)
	if err != nil {
		panic(err.Error())
	}
	for !done {
		//time.Sleep(1*time.Millisecond)
		i++
		counter.Incr(2)
		if _, err := stmt.Exec(now+i, string(now+i)); err != nil {
			panic(err)
		}
		_ = stmt2
		//if _, err := stmt2.Exec(now+i, fmt.Sprintf("x%d", now+i)); err != nil {
			//panic(err)
		//}
		if i%1000 == 0 {
			fmt.Printf("QPS: %d\n", counter.Rate())
		}
		if i%1 == 0 {
			if err := tx.Commit(); err != nil {
				panic(err)
			}
			//fmt.Printf(".")
			tx, stmt, err = PrepareTx(db, query)
			if err != nil {
				panic(err.Error())
			}
			if err := tx2.Commit(); err != nil {
				panic(err)
			}
			//fmt.Printf(".")
			tx2, stmt2, err = PrepareTx(db, query2)
			if err != nil {
				panic(err.Error())
			}
		}
	}
}
