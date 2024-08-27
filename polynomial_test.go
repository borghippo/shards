package shards

import "testing"

func TestEvaluate(t *testing.T) {
	p := polynomial{
		coefficients: []byte{3, 2, 3},
	}

	var want byte = 58
	res := p.evaluate(5)

	if want != res {
		t.Errorf("got %d, want %d", res, want)
	}
}

func TestInterpolate(t *testing.T) {
	xValues := []byte{170, 19, 101}
	yValues := []byte{42, 31, 21}
	x := 0

	res := interpolate(xValues, yValues, byte(x))
	want := 104

	if res != 104 {
		t.Errorf("got %d, want %d", res, want)
	}
}
