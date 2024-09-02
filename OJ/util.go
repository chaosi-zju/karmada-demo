package main

import (
	"fmt"
	"math"
)

func ConstructTree(sp []int) *TreeNode {
	if len(sp) == 0 {
		return nil
	}
	root := &TreeNode{Val: sp[0]}
	sp = sp[1:]
	tree := []*TreeNode{root}

	for len(tree) > 0 && len(sp) > 0 {
		cur := tree[0]
		if len(sp) > 0 {
			if sp[0] != math.MinInt {
				cur.Left = &TreeNode{Val: sp[0]}
				tree = append(tree, cur.Left)
			}
			sp = sp[1:]
		}
		if len(sp) > 0 {
			if sp[0] != math.MinInt {
				cur.Right = &TreeNode{Val: sp[0]}
				tree = append(tree, cur.Right)
			}
			sp = sp[1:]
		}
		tree = tree[1:]
	}

	return root
}

func printTree(root *TreeNode) {
	core := func() (ans []int) {
		if root == nil {
			return []int{math.MinInt}
		}
		q := []*TreeNode{root}
		for len(q) > 0 {
			cur := q[0]
			q = q[1:]
			if cur == nil {
				ans = append(ans, math.MinInt)
				continue
			}
			ans = append(ans, cur.Val)
			q = append(q, cur.Left)
			q = append(q, cur.Right)
		}
		return ans
	}

	sp := core()
	i := len(sp) - 1
	for ; i >= 0; i-- {
		if sp[i] != math.MinInt {
			break
		}
	}

	for _, num := range sp[:i+1] {
		if num == math.MinInt {
			fmt.Printf("null ")
		} else {
			fmt.Printf("%d ", num)
		}
	}
	fmt.Println()
}
