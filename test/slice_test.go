package main

import (
	"fmt"
	"reflect"
	"testing"
)

func Test_Delete(t *testing.T) {
	a := []int{0, 1, 2, 3, 4, 5}
	fmt.Println(remove(a, 0))
	a = []int{0, 1, 2, 3, 4, 5}
	fmt.Println(remove(a, 1))
	a = []int{0, 1, 2, 3, 4, 5}
	fmt.Println(remove(a, 2))
	a = []int{0, 1, 2, 3, 4, 5}
	fmt.Println(remove(a, 3))
	a = []int{0, 1, 2, 3, 4, 5}
	fmt.Println(remove(a, 4))
	a = []int{0, 1, 2, 3, 4, 5}
	fmt.Println(remove(a, 5))
	a = []int{0, 1, 2, 3, 4, 5}
	fmt.Println(a[6:])
}

func remove(arr []int, k int) []int {
	return append(arr[0:k], arr[k+1:]...)
}

func Test_DeepEqual(t *testing.T) {
	a := make([]string, 0, 3)
	b := make([]string, 0)

	a = append(a, "1")
	a = append(a, "2")

	b = append(b, "1")
	b = append(b, "2")

	fmt.Println(reflect.DeepEqual(a, b))
}

func Test_Print(t *testing.T) {
	fmt.Printf("%q\n", "\"hello\"")
	a := "haha"
	fmt.Printf("%+v\n", &a)
	fmt.Printf("%v\n", &a)
	fmt.Printf("%#v\n", &a)
	fmt.Printf("%p\n", &a)
	fmt.Printf("%#p\n", &a)
}
