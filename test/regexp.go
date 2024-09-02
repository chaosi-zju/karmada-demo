package main

import (
	"encoding/json"
	"fmt"
	"regexp"
	"strconv"
)
import appsv1 "k8s.io/api/apps/v1"

func testRegexp1() {
	status := appsv1.DeploymentStatus{
		Replicas:            12,
		UpdatedReplicas:     2,
		ReadyReplicas:       3,
		AvailableReplicas:   4,
		UnavailableReplicas: 5,
	}
	bytes, err := json.Marshal(status)
	if err != nil {
		panic(err)
	}

	fmt.Printf("%s\n", bytes)

	reg, err := regexp.Compile(`"replicas":(\d+)`)
	if err != nil {
		panic(err)
	}

	arr := reg.FindSubmatch(bytes)
	fmt.Println(arr)

	if len(arr) < 1+reg.NumSubexp() {
		fmt.Printf("%d\n", len(arr))
		return
	}

	fmt.Printf("%s\n", arr[1])
	num, err := strconv.Atoi(string(arr[1]))
	fmt.Printf("%d, %+v\n", num, err)
}

// replicasReg regexp to parse `replicas` field in AggregatedStatusItem.Status.
// the part of `"replicas":` matches sub string started with `"replicas":`;
// the part of `\d+` matched one or more digital number;
// the part of `()` means the inner element is to be extracted.
var replicasReg = regexp.MustCompile(`"replicas":(\d+)`)

// e.g: raw = {"replicas":12,"readyReplicas":3}, then the replicas value `12` is expected to be extracted.
func getStatusReplicas(raw []byte) int32 {
	ret := replicasReg.FindSubmatch(raw)
	// if regexp not match in raw, ret = nil
	if len(ret) == 0 {
		return 0
	}
	// if regexp matches, ret must return two item, ret[0] is the matched sub string, ret[1] is value extracted by `()`
	replicas, err := strconv.Atoi(string(ret[1]))
	if err != nil {
		return 0
	}
	return int32(replicas)
}
