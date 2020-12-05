package main

import "dbs/mysql"

import "fmt"


func main(){
	
	userInfo := mysql.queryField(1)
	fmt.Println(userInfo)
}