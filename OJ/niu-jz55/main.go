package niu_jz55

type TreeNode struct {
	Val   int
	Left  *TreeNode
	Right *TreeNode
}

func TreeDepth(root *TreeNode) int {
	if root == nil {
		return 0
	}
	l := TreeDepth(root.Left) + 1
	r := TreeDepth(root.Right) + 1
	return max(l, r)
}
