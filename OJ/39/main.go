package _39

import (
	"slices"
	"sort"
)

func combinationSum(candidates []int, target int) [][]int {
	sort.Ints(candidates)
	ans := make([][]int, 0)
	path := make([]int, 0)

	var dfs func(int, int)
	dfs = func(idx, left int) {
		if left == 0 {
			ans = append(ans, slices.Clone(path))
			return
		}
		if left < 0 || idx >= len(candidates) {
			return
		}
		dfs(idx+1, left)

		path = append(path, candidates[idx])
		dfs(idx, left-candidates[idx])
		path = path[:len(path)-1]
	}
	dfs(0, target)

	return ans
}
