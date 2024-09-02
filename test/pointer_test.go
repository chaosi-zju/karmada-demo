package main

import "testing"

type A struct {
	Name string `json:"name"`
}

func Test_Pointer_1(t *testing.T) {
	a := &A{Name: "alice"}
	changeName(a)
	t.Logf("%+v", a)
}

func changeName(b *A) {
	*b = A{Name: "bob"}
}
