package _44

func isMatch(s string, p string) bool {
	m, n := len(s), len(p)
	dp := make([][]bool, m+1)
	for i := 0; i <= m; i++ {
		dp[i] = make([]bool, n+1)
	}

	dp[m][n] = true
	for i := n - 1; i >= 0; i-- {
		dp[m][i] = (p[i] == '*') && dp[m][i+1]
	}

	for i := m - 1; i >= 0; i-- {
		for j := n - 1; j >= 0; j-- {
			switch p[j] {
			case '*':
				dp[i][j] = dp[i+1][j] || dp[i][j+1]
			case '?':
				dp[i][j] = dp[i+1][j+1]
			default:
				dp[i][j] = (s[i] == p[j]) && dp[i+1][j+1]
			}
		}
	}
	return dp[0][0]
}
