package _144

type TreeNode struct {
	Val   int
	Left  *TreeNode
	Right *TreeNode
}

func mirrorTree(root *TreeNode) *TreeNode {
	ans := make([]*TreeNode, 0)
	if root != nil {
		ans = append(ans, root)
	}
	for len(ans) > 0 {
		cur := ans[0]
		ans = ans[1:]

		cur.Left, cur.Right = cur.Right, cur.Left

		if cur.Left != nil {
			ans = append(ans, cur.Left)
		}
		if cur.Right != nil {
			ans = append(ans, cur.Right)
		}
	}

	return root
}
