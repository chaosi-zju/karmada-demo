package main

import (
	"context"
	"fmt"
	"testing"
	"time"

	"k8s.io/apimachinery/pkg/util/wait"
)

func Test_waittest(t *testing.T) {
	cnt := 1
	fmt.Printf("%+v\n", time.Now())

	err := wait.PollUntilContextTimeout(context.Background(), 1*time.Second, 110*time.Second, true, func(ctx context.Context) (done bool, err error) {
		fmt.Printf("%d: %+v\n", cnt, time.Now())
		if cnt > 4 {
			return true, nil
		}
		time.Sleep(1 * time.Second)
		cnt++
		return false, fmt.Errorf("xxx")
	})

	fmt.Println(err)
}
