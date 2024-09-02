package main

import (
	"fmt"
	"sync"
	"testing"
)

var once sync.Once

func Test_once(t *testing.T) {
	for i := 0; i < 10; i++ {
		once.Do(func() {
			fmt.Println(1)
		})
		once.Do(func() {
			fmt.Println(2)
		})
		once.Do(func() {
			fmt.Println(3)
		})
	}
}
