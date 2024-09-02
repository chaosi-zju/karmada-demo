package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"runtime/debug"

	appsv1 "k8s.io/api/apps/v1"
	"k8s.io/apimachinery/pkg/runtime"
)

func main1() {
	fmt.Println(test())
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
