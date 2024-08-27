package shards

import (
	"crypto/rand"
)

type polynomial struct {
	coefficients []byte
}

func newRandPolynomial(intercept, degree byte) (polynomial, error) {
	p := polynomial{
		coefficients: make([]byte, degree+1),
	}

	p.coefficients[0] = intercept

	if _, err := rand.Read(p.coefficients[1:]); err != nil {
		return p, err
	}

	return p, nil
}

func (p polynomial) evaluate(x byte) byte {
	degree := len(p.coefficients) - 1
	res := p.coefficients[degree]

	for i := degree - 1; i >= 0; i-- {
		res = add(p.coefficients[i], mult(x, res))
	}

	return res
}

func interpolate(xValues, yValues []byte, x byte) byte {
	numPoints := len(xValues)
	var res byte
	for i := 0; i < numPoints; i++ {
		var basis byte = 1
		for j := 0; j < numPoints; j++ {
			if i == j {
				continue
			}
			num := add(x, xValues[j])
			denom := add(xValues[i], xValues[j])
			term := div(num, denom)
			basis = mult(basis, term)
		}
		group := mult(yValues[i], basis)
		res = add(res, group)
	}

	return res
}
