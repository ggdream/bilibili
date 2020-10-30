package main

import "fmt"


func main() {
	if err := tApp(); err != nil {
		fmt.Println(err)
		return
	}
}
