package b

import (
	"fmt"
	_ "github.com/chaosi-zju/demo/test/packagetest/c"
	_ "github.com/chaosi-zju/demo/test/packagetest/d"
)

func init() {
	fmt.Println("init b")
}
