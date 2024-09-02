package main

import (
	"fmt"
)

const perHand = 6500
const pastEarn = float32(-1459)

var hands = []float32{2, 2, 1, 1, 1, -7, 2}
var prices = []float32{1.591, 1.560, 1.553, 1.545, 1.530, 1.550, 1.542}
var curPrice = float32(1.510)

func main() {
	printEarningWhenPrice(curPrice)

	addHolding(1, 1.510)
	printEarningWhenPrice(1.514)

	addHolding(2, 1.500)
	printEarningWhenPrice(1.500)

	addHolding(2, 1.486)
	printEarningWhenPrice(1.486)

	printEarningWhenPrice(1.542)
	printEarningWhenPrice(1.560)
}

func printEarningWhenPrice(price float32) {
	var sumHands, paid, earn, rest = float32(0), float32(0), float32(0), float32(0)
	for i, hand := range hands {
		sumHands += hand
		paid += hands[i] * perHand * prices[i]
	}
	rest = sumHands * perHand * price
	earn = pastEarn + rest - paid
	payback := (rest - earn) / (sumHands * perHand)
	fmt.Printf("\ntotal paid: %.f (%.f * %.d = %.f)\n", paid, sumHands, perHand, sumHands*perHand)
	fmt.Printf("payback price: %.3f (current: %.3f, sum earn: %.f)\n", payback, price, earn)
	fmt.Println("=====")
}

func addHolding(hand, price float32) {
	hands = append(hands, hand)
	prices = append(prices, price)
}
