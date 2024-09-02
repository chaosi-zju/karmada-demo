package _69

func mySqrt(x int) int {
	if x <= 0 {
		return 0
	}
	l, r := 1, x
	for {
		mid := l + ((r - l) >> 2)
		if mid*mid > x {
			r = mid - 1
		} else {
			if (mid+1)*(mid+1) > x {
				return mid
			}
			l = mid + 1
		}
	}
}
