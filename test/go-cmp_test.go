package main

import (
	"github.com/google/go-cmp/cmp"
	"k8s.io/klog/v2"
	"testing"
)

func Test_Diff(t *testing.T) {
	klog.Infof("%+v", cmp.Diff([]byte("hello"), []byte("world")))
}
