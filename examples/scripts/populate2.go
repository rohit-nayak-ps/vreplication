package main

import (
	"database/sql"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"github.com/paulbellamy/ratecounter"
	"time"
)

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
	query := "insert into c1m (c1, val2) values (?,?)"
	i = 0
	db, err := sql.Open("mysql", "msandbox:msandbox@tcp(127.0.0.1:19327)/test")
	//db, err := sql.Open("mysql", "root@tcp(127.0.0.1:19327)/load1")
	fmt.Println("connection opened")
	if err != nil {
		panic(err.Error())
	}
	defer db.Close()
	now := time.Now().UnixNano()
	tx, stmt, err := PrepareTx(db, query)
	if err != nil {
		panic(err.Error())
	}
	for !done {
		time.Sleep(10*time.Millisecond)
		i++
		counter.Incr(1)
		if _, err := stmt.Exec(fmt.Sprintf("%d", now+i), fmt.Sprintf("val2-%d", now+i)); err != nil {
			panic(err)
		}
		if i%1000 == 0 {
			fmt.Printf("QPS: %d\n", counter.Rate())
		}
		if i%1 == 0 {
			if err := tx.Commit(); err != nil {
				panic(err)
			}
			tx, stmt, err = PrepareTx(db, query)
			if err != nil {
				panic(err.Error())
			}
		}
	}
}
