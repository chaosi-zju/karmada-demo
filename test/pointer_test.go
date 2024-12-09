package main

import (
	"fmt"
	"testing"
)

func Test_Pointer_1(t *testing.T) {
	a := &A{Name: "alice"}
	changeName(a)
	t.Logf("%+v", a)
}

func changeName(b *A) {
	*b = A{Name: "bob"}
}

func Test_PTR(t *testing.T) {
	objs := make([]A, 0)
	objPtrs := make([]*A, 0)

	objs = append(objs, A{Name: "ZhangSan"})
	objs = append(objs, A{Name: "Lisi"})
	objs = append(objs, A{Name: "Wangwu"})

	for _, obj := range objs {
		fmt.Printf("%p\n", &obj)
		pointer := &obj
		//pointer := ptr.To(obj)
		objPtrs = append(objPtrs, pointer)
	}

	for _, item := range objPtrs {
		fmt.Printf("%+v\n", item.Name)
	}
}
