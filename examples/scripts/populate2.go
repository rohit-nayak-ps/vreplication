package main
import (
    "fmt"
    "time"
    "database/sql"
    _ "github.com/go-sql-driver/mysql"
    "github.com/paulbellamy/ratecounter"
)

func PrepareTx(db *sql.DB,qry string) (tx *sql.Tx, s *sql.Stmt, e error) {
 if tx,e=db.Begin(); e!=nil {
  return
 }

 if s, e = tx.Prepare(qry);e!=nil {
	 panic(e.Error())
 }
 return
}

func main() {
    counter := ratecounter.NewRateCounter(1 * time.Second)
    done := false
    var i int64
    query := "insert into c1(c1) values (?)"
    i = 0
    db, err := sql.Open("mysql", "msandbox:msandbox@tcp(127.0.0.1:19327)/test")
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
	    //time.Sleep(1 * time.Millisecond)
		i++
		counter.Incr(1)
		if _,err := stmt.Exec(now+i); err != nil {
				panic(err)
		}
		if i % 10000  == 0 {
			fmt.Printf("QPS: %d\n", counter.Rate())
			if err := tx.Commit(); err!=nil {
				panic(err)
			}
			tx, stmt, err = PrepareTx(db, query)
			if err != nil {
				panic(err.Error())
			}
		}
    }

}
