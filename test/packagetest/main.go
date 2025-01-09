package main


import (
	"fmt"
	_ "github.com/chaosi-zju/demo/test/packagetest/c"
	_ "github.com/chaosi-zju/demo/test/packagetest/d"
)

func init() {
	fmt.Println("main")
}

func main() {
	fmt.Println("Hello World")
}
