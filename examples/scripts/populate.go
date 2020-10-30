package main

import (
    "fmt"
    "time"
    "database/sql"
    _ "github.com/go-sql-driver/mysql"
    "github.com/paulbellamy/ratecounter"
    "github.com/brianvoe/gofakeit"
    "strings"
)

func main() {
    // Open up our database connection.
    // I've set up a database on my local machine using phpmyadmin.
    // The database is called testDb

    gofakeit.Seed(0)
    // perform a db.Query insert
    counter := ratecounter.NewRateCounter(1 * time.Second)
    done := false
    var i int64

    db, err := sql.Open("mysql", "msandbox:msandbox@tcp(127.0.0.1:19327)/prod-charlotte-1")
		fmt.Println("connection opened")
		if err != nil {
			panic(err.Error())
		}
		defer db.Close()
    now := time.Now().UnixNano()
    _ = now
    rows, err := db.Query("select max(id) from Email")
    if err != nil {
      panic(err.Error())
    }
    if rows != nil {
      rows.Close()
    }
    var maxId int
    rows.Scan(&maxId)
    fmt.Printf("maxid is %d\n", maxId)
    i = int64(maxId)
		db.Query("BEGIN")

    limit := func(s string, i int) string {
      s = strings.ReplaceAll(s, "'", "")
      if len(s) <= i {
        return s
      }
      return s[:i]
    }
    for !done {

		i++
	    	// if there is an error opening the connection, handle it
    //query := fmt.Sprintf("INSERT INTO c1 VALUES ( %d, 'TEST' )", now+i)
    // query := fmt.Sprintf("insert into rule values('%d', now(), now(), '%s', '%s', '%s');",
    //         i, gofakeit.Name(), gofakeit.Name(), gofakeit.Name())
    query := "insert into Email (id, created, ari, email_thread_id, from_address, body) "
    query += fmt.Sprintf("values (%d, '%s', '%s', %s, '%s', '%s')",
      i, time.Now().UTC().Format("2006-01-02 15:04:05"), limit(gofakeit.Name(), 15), gofakeit.CreditCardNumber(nil),
      strings.ReplaceAll(gofakeit.Company(),"'",""), strings.ReplaceAll(gofakeit.HackerPhrase(),"'",""))
    rows, err := db.Query(query)

		if err != nil {
			panic(err.Error())
		}
		if rows != nil {
			rows.Close()
		}
		counter.Incr(1)
		if i % 1000  == 0 {
			db.Query("COMMIT")
			fmt.Printf("QPS: %d\n", counter.Rate())
			db.Query("BEGIN")
			/*
			rows, err := db.Query(fmt.Sprintf("update c1 set val2 = 'x%d' where c1 < 1000", now))
			if err != nil {
				panic(err.Error())
			}

			if rows != nil {
				rows.Close()
			}
			*/

		}
    }

}
