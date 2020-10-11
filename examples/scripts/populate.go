package main

import (
    "fmt"
    "time"
    "database/sql"
    _ "github.com/go-sql-driver/mysql"
    "github.com/paulbellamy/ratecounter"
)

func main() {
    // Open up our database connection.
    // I've set up a database on my local machine using phpmyadmin.
    // The database is called testDb


    // perform a db.Query insert
    counter := ratecounter.NewRateCounter(1 * time.Second)
    done := false
    var i int64
    i = 0
    		db, err := sql.Open("mysql", "msandbox:msandbox@tcp(127.0.0.1:19327)/test")
		fmt.Println("connection opened")
		if err != nil {
			panic(err.Error())
		}
		defer db.Close()
    		now := time.Now().UnixNano()
		db.Query("BEGIN")
    for !done {
	    	
		i++
	    	// if there is an error opening the connection, handle it
		rows, err := db.Query(fmt.Sprintf("INSERT INTO c1 VALUES ( %d, 'TEST' )", now+i))
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
