package _78

import (
	"strconv"
	"testing"
)

func Test78(t *testing.T) {
	tests := []struct {
		nums []int
		want [][]int
	}{
		{
			nums: []int{1, 2, 3},
			want: [][]int{{}, {1}, {2}, {1, 2}, {3}, {1, 3}, {2, 3}, {1, 2, 3}},
		},
		{
			nums: []int{0},
			want: [][]int{{}, {0}},
		},
	}
	for i, tt := range tests {
		t.Run(strconv.Itoa(i), func(t *testing.T) {
			got := subsets(tt.nums)
			t.Logf("got: %+v, want: %+v", got, tt.want)
		})
	}
}
