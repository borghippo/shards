package tests

import shards ".."
import "core:testing"

@(test)
test_add :: proc(t: ^testing.T) {
	want: u8 = 100
	got := shards.add(11, 111)
	testing.expect_value(t, got, want)
}

@(test)
test_mult :: proc(t: ^testing.T) {
	want: u8 = 35
	got := shards.mult(240, 120)
	testing.expect_value(t, got, want)
}

@(test)
test_div :: proc(t: ^testing.T) {
	want: u8 = 62
	got := shards.div(240, 250)
	testing.expect_value(t, got, want)
}

@(test)
test_inv :: proc(t: ^testing.T) {
	want: u8 = 136
	got := shards.inv(155)
	testing.expect_value(t, got, want)
}

@(test)
test_evaluate :: proc(t: ^testing.T) {
	p := shards.polynomial{3, 2, 3}

	want: u8 = 58
	got := shards.evaluate_polynomial(p, 5)

	testing.expect_value(t, got, want)
}

@(test)
test_interpolate :: proc(t: ^testing.T) {
	x_values := []u8{170, 19, 101}
	y_values := []u8{42, 31, 21}
	x: u8 = 0

	got := shards.interpolate_polynomial(x_values, y_values, x)
	want: u8 = 104

	testing.expect_value(t, got, want)
}

@(test)
test_split_and_recover :: proc(t: ^testing.T) {
	secret := []u8{'g', 'l', 'a', 's', 's'}
	threshold := 4
	parts := 6

	shares, _ := shards.split(secret, parts, threshold)
	defer {
		for i := 0; i < len(shares); i += 1 {
			delete(shares[i])
		}
		delete(shares)
	}

	testing.expect_value(t, len(shares), parts)
	testing.expect_value(t, len(shares[0]), len(secret) + 1)

	recovered_secret, _ := shards.recover(shares[:threshold])
	defer delete(recovered_secret)

	for b, i in recovered_secret {
		testing.expect_value(t, b, secret[i])
	}
}

@(test)
test_split_errors :: proc(t: ^testing.T) {
	secret := []u8{'e', 'r', 'r', 'o', 'r'}
	threshold := 5
	parts := 4

	_, err := shards.split(secret, parts, threshold)
	testing.expect_value(t, err, shards.Split_Error.Parts_Less_Than_Threshold)

	threshold = 25
	parts = 256
	_, err = shards.split(secret, parts, threshold)
	testing.expect_value(t, err, shards.Split_Error.Too_Many_Parts)

	threshold = 1
	parts = 4
	_, err = shards.split(secret, parts, threshold)
	testing.expect_value(t, err, shards.Split_Error.Insufficient_Threshold)

	secret = []u8{}
	threshold = 4
	parts = 6
	_, err = shards.split(secret, parts, threshold)
	testing.expect_value(t, err, shards.Split_Error.Secret_Empty)
}

@(test)
test_recover_errors :: proc(t: ^testing.T) {
	shares := [][]u8{{75, 208, 32, 180, 22, 95}}
	_, err := shards.recover(shares)
	testing.expect_value(t, err, shards.Recover_Error.Insufficient_Shares)

	shares = [][]u8{{75}, {25, 235, 123}}
	_, err = shards.recover(shares)
	testing.expect_value(t, err, shards.Recover_Error.Insufficient_Share_Bytes)

	shares = [][]u8{{75, 208, 32, 180, 22, 95}, {25, 235, 123}}
	_, err = shards.recover(shares)
	testing.expect_value(t, err, shards.Recover_Error.Share_Length_Mismatch)
}
