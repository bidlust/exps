package dbs

import
(
	"database/sql"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"log"
    "time"
)

var MysqlDb *sql.DB
var MysqlDbErr error

const (
    USER_NAME = "sunlight"
    PASS_WORD = "Sunlight2017!@"
    HOST      = "116.63.128.105"
    PORT      = "3306"
    DATABASE  = "sunlight"
    CHARSET   = "utf8mb4"
)

func init(){
	db_dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=%s", USER_NAME, PASS_WORD, HOST, PORT, DATABASE, CHARSET)
	MysqlDb, MysqlDbErr = sql.Open("mysql", db_dsn)
	if MysqlDbErr != nil {
		log.Println("db dsn: " + db_dsn)
		panic("Mysql Data Source Config Error! " + MysqlDbErr.Error())
	}

    MysqlDb.SetMaxOpenConns(100)
    MysqlDb.SetMaxIdleConns(20)
    MysqlDb.SetConnMaxLifetime(100 * time.Second)
	
	if MysqlDbErr = MysqlDb.Ping(); nil != MysqlDbErr {
        panic("Mysql DB Connect Error : " + MysqlDbErr.Error())
    }
}

