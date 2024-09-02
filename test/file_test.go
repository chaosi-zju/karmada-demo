package main

import (
	"io"
	"log"
	"os"
	"testing"
)

func Test_Create(t *testing.T) {
	filename := "./a.txt"

	f, err := os.Create(filename)
	if err != nil {
		t.Fatal(err)
	}
	defer f.Close()

	if _, err = io.WriteString(f, "hello"); err != nil {
		t.Fatal(err)
	}
}

func Test_OpenFile(t *testing.T) {
	filename := "./b.txt"

	f, err := os.OpenFile(filename, os.O_CREATE|os.O_RDWR, 0640)
	if err != nil {
		t.Fatal(err)
	}
	defer f.Close()

	if _, err = io.WriteString(f, "hello"); err != nil {
		t.Fatal(err)
	}
}

func Test_WriteFile(t *testing.T) {
	filename := "./c.txt"

	err := os.WriteFile(filename, []byte("hello"), 0600)
	if err != nil {
		t.Fatal(err)
	}

	err = os.WriteFile(filename, []byte("world"), 0600)
	if err != nil {
		t.Fatal(err)
	}
}

func Test_Open(t *testing.T) {
	file, err := os.OpenFile("./d.txt", os.O_CREATE|os.O_APPEND|os.O_RDWR, 0600)
	if err != nil {
		log.Fatal(err)
	}

	file.WriteString("hello")
	file.WriteString("world")
}
