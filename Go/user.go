package dbs

import "fmt"
import "os"

type User struct {
	Id int64 `db:"id"`
	Name string `db:"name"`
	Age int `db:"age"`
}



func QueryField( id int ) User {
	
	user := User{}
	row := MysqlDb.QueryRow("select id, name, age from users  where id=?", id)
	if err := row.Scan(&user.Id, &user.Name, &user.Age); err != nil{
		fmt.Printf("Query Failed! Error Message: %v", err )
		os.Exit(1)
	}
	//defer row.Close()
	return user 
}

func QueryALL( offset , limit int ) []User{
	userArray := make( []User, 0)
	rows, _  := MysqlDb.Query(" select `id`, `name`, `age` from users limit ?, ? ", offset, limit )
	var user User
	for rows.Next(){
		rows.Scan(&user.Id, &user.Name, &user.Age)
		userArray = append(userArray, user)
	}
	return userArray
}

func dbInsert(user User) (lastInsertID, rowsaffected int64) {
	ret, _ := MysqlDb.Exec("insert into users(`name`, `age`) values(?, ?)", user.Name, user.Age)
	a,_ := ret.LastInsertId()
	b,_ := ret.RowsAffected()
	return a, b
}

func dbUpdate() {

    ret,_ := MysqlDb.Exec("UPDATE users set age=? where id=?","100",1)
    upd_nums,_ := ret.RowsAffected()

    fmt.Println("RowsAffected:",upd_nums)
}

func dbDelete() {

    ret,_ := MysqlDb.Exec("delete from users where id=?",1)
    del_nums,_ := ret.RowsAffected()

    fmt.Println("RowsAffected:",del_nums)
}
