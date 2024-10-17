package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"runtime/debug"
	"time"

	appsv1 "k8s.io/api/apps/v1"
	"k8s.io/apimachinery/pkg/runtime"
)

func main() {
	go testPanic()
	time.Sleep(time.Minute)
	fmt.Println("ok")
}

func test() (status *runtime.RawExtension) {
	defer func() {
		if bytes.Equal(status.Raw, []byte("{}")) {
			status = nil
		}
	}()
	deploy := appsv1.DeploymentStatus{}
	statusJSON, _ := json.Marshal(deploy)
	status = &runtime.RawExtension{Raw: statusJSON}
	fmt.Printf("%+v\n", status)
	debug.Stack()
	return
}

func testPanic() {
	defer func() {
		if r := recover(); r != nil {
			fmt.Println("Recovered. Error:\n", r)
		}
	}()
	for {
		time.Sleep(time.Second)
		mayPanic()
		fmt.Println("error")
	}
}

func mayPanic() {
	panic("a problem")
}
