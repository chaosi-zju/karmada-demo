package _78

import "slices"

//不含重复元素集合的所有子集
//
//给定一组不含重复元素的整数数组 nums，返回该数组所有可能的子集（幂集）
//
//说明：解集不能包含重复的子集

func subsets(nums []int) [][]int {
	ans := make([][]int, 0)
	path := make([]int, 0)

	var dfs func(i int)
	dfs = func(i int) {
		if i == len(nums) {
			ans = append(ans, slices.Clone(path))
			return
		}
		dfs(i + 1)

		path = append(path, nums[i])
		dfs(i + 1)
		path = path[:len(path)-1]
	}

	dfs(0)
	return ans
}
