package main

import "fmt"

type TreeNode struct {
	Val   int
	Left  *TreeNode
	Right *TreeNode
}

type ListNode struct {
	Val  int
	Next *ListNode
}

type Node struct {
	Val   int
	Left  *Node
	Right *Node
	Next  *Node
}

func main() {
	A := &TreeNode{Val: 1, Left: &TreeNode{Val: 2, Left: &TreeNode{Val: 4}}, Right: &TreeNode{Val: 3}}
	B := &TreeNode{Val: 3}
	fmt.Println(isSubStructure(A, B))
}

func isSubStructure(A *TreeNode, B *TreeNode) bool {
	if A == nil || B == nil {
		return false
	}
	var subTree func(A *TreeNode, B *TreeNode) bool
	subTree = func(a *TreeNode, b *TreeNode) bool {
		if b == nil {
			return true
		}
		if a == nil {
			return false
		}
		if a.Val != b.Val {
			return false
		}
		return subTree(a.Left, b.Left) && subTree(a.Right, b.Right)
	}
	return subTree(A, B) || isSubStructure(A.Left, B) || isSubStructure(A.Right, B)
}
