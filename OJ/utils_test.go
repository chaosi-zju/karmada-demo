package main

import (
	"strings"
	"testing"
)

func Test_StringToSlice(t *testing.T) {
	t.Logf(strToSlice("[[],[1],[2],[1,2],[3],[1,3],[2,3],[1,2,3]]"))

}

func strToSlice(str string) string {
	str = strings.ReplaceAll(str, "]", "}")
	return strings.ReplaceAll(str, "[", "{")
}
