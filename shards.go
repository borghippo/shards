package shards

import (
	"errors"
	"math/rand"
)

func Split(secret []byte, parts, threshold int) ([][]byte, error) {
	if parts < threshold {
		return nil, errors.New("cannot have less parts than threshold")
	}

	if threshold < 2 {
		return nil, errors.New("threshold must be greater than one")
	}

	if len(secret) == 0 {
		return nil, errors.New("secret is empty")
	}

	xCoords := rand.Perm(255)

	shares := make([][]byte, parts)
	for i := range shares {
		shares[i] = make([]byte, len(secret)+1)
		shares[i][len(secret)] = byte(xCoords[i]) + 1
	}

	for b, val := range secret {
		p, err := newRandPolynomial(val, byte(threshold-1))
		if err != nil {
			return nil, err
		}

		for i := 0; i < parts; i++ {
			x := byte(xCoords[i]) + 1
			y := p.evaluate(x)
			shares[i][b] = y
		}
	}

	return shares, nil
}

func Reconstruct(shares [][]byte) ([]byte, error) {
	if len(shares) < 2 {
		return nil, errors.New("must have at least two parts")
	}

	partLen := len(shares[0])

	secret := make([]byte, partLen-1)

	xValues := make([]byte, len(shares))
	yValues := make([]byte, len(shares))

	for i, part := range shares {
		xValues[i] = part[partLen-1]
	}

	for b := range secret {
		for i, share := range shares {
			yValues[i] = share[b]
		}

		intercept := interpolate(xValues, yValues, 0)

		secret[b] = intercept
	}

	return secret, nil
}
