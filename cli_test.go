package main

import (
	"fmt"
	"testing"
)

func TestCli(t *testing.T) {
	if err := tApp(); err != nil {
		fmt.Println(err)
		return
	}
}
