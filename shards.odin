package shards

import "core:crypto"
import "core:math/rand"

// AES irreducible polynomial
IRREDUCIBLE_POLYNOMIAL :: 0x1B

MAX_PARTS :: 255
MIN_THRESHOLD :: 2
MIN_SHARE_BYTES :: 2

polynomial :: []u8

Split_Error :: enum {
	None,
	Parts_Less_Than_Threshold,
	Too_Many_Parts,
	Insufficient_Threshold,
	Secret_Empty,
}

Recover_Error :: enum {
	None,
	Insufficient_Shares,
	Insufficient_Share_Bytes,
	Share_Length_Mismatch,
}

// Addition in GF(2^8)
add :: proc(a, b: u8) -> u8 {
	return a ~ b
}

// Multiplication in GF(2^8)
mult :: proc(a, b: u8) -> u8 {
	a := a
	b := b
	p: u8 = 0

	for i := 0; i < 8; i += 1 {
		p ~= a & -(b & 1)
		b >>= 1
		overflow := a >> 7
		a <<= 1
		a ~= IRREDUCIBLE_POLYNOMIAL & -overflow
	}

	return p
}

// Division in GF(2^8)
div :: proc(a, b: u8) -> u8 {
	if (b == 0) {
		panic("divide by zero")
	}

	return mult(a, inv(b))
}

// Inverse of element in GF(2^8)
inv :: proc(a: u8) -> u8 {
	a2 := mult(a, a)
	a3 := mult(a2, a)
	a6 := mult(a3, a3)
	a7 := mult(a6, a)
	a14 := mult(a7, a7)
	a15 := mult(a14, a)
	a30 := mult(a15, a15)
	a60 := mult(a30, a30)
	a120 := mult(a60, a60)
	a127 := mult(a120, a7)
	a254 := mult(a127, a127)

	return a254
}

// Creates a polynomial with randomly generated coefficient values
make_rand_polynomial :: proc(intercept, degree: u8) -> polynomial {
	p := make(polynomial, degree + 1)

	p[0] = intercept

	crypto.rand_bytes(p[1:])

	return p
}

// Evaluates polynomial at given x
evaluate_polynomial :: proc(p: polynomial, x: u8) -> u8 {
	degree := len(p) - 1
	res := p[degree]

	for i := degree - 1; i >= 0; i -= 1 {
		res = add(p[i], mult(x, res))
	}

	return res
}

// Find polynomial using Lagrange interpotation and evaluate at x
interpolate_polynomial :: proc(x_values, y_values: []u8, x: u8) -> u8 {
	num_points := len(x_values)
	res: u8
	for i := 0; i < num_points; i += 1 {
		basis: u8 = 1
		for j := 0; j < num_points; j += 1 {
			if i == j {
				continue
			}
			num := add(x, x_values[j])
			denom := add(x_values[i], x_values[j])
			term := div(num, denom)
			basis = mult(basis, term)
		}
		group := mult(y_values[i], basis)
		res = add(res, group)
	}

	return res
}

// Splits a secret into shares with a threshold for recovery
split :: proc(secret: []u8, parts, threshold: int) -> ([][]u8, Split_Error) {
	if parts < threshold {
		return nil, Split_Error.Parts_Less_Than_Threshold
	}

	if parts > MAX_PARTS {
		return nil, Split_Error.Too_Many_Parts
	}

	if threshold < MIN_THRESHOLD {
		return nil, Split_Error.Insufficient_Threshold
	}

	if len(secret) == 0 {
		return nil, Split_Error.Secret_Empty
	}

	x_coords := rand.perm(255)
	defer delete(x_coords)

	shares := make([][]u8, parts)
	for i := 0; i < len(shares); i += 1 {
		shares[i] = make([]u8, len(secret) + 1)
		shares[i][len(secret)] = u8(x_coords[i]) + 1
	}

	for val, b in secret {
		p := make_rand_polynomial(val, u8(threshold) - 1)
		defer delete(p)

		for i := 0; i < parts; i += 1 {
			x := u8(x_coords[i]) + 1
			y := evaluate_polynomial(p, x)
			shares[i][b] = y
		}
	}

	return shares, nil
}

// Attempts to recover secret given a number of shares
recover :: proc(shares: [][]u8) -> ([]u8, Recover_Error) {
	if len(shares) < MIN_THRESHOLD {
		return nil, Recover_Error.Insufficient_Shares
	}

	share_len := len(shares[0])
	if share_len < MIN_SHARE_BYTES {
		return nil, Recover_Error.Insufficient_Share_Bytes
	}

	for i := 1; i < len(shares); i += 1 {
		if len(shares[i]) != share_len {
			return nil, Recover_Error.Share_Length_Mismatch
		}
	}

	secret := make([]u8, share_len - 1)

	x_values := make([]u8, len(shares))
	defer delete(x_values)
	y_values := make([]u8, len(shares))
	defer delete(y_values)

	for part, i in shares {
		x_values[i] = part[share_len - 1]
	}

	for b := 0; b < len(secret); b += 1 {
		for share, i in shares {
			y_values[i] = share[b]
		}

		intercept := interpolate_polynomial(x_values, y_values, 0)
		secret[b] = intercept
	}

	return secret, nil
}
