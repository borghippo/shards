package shards

import "testing"

func TestAdd(t *testing.T) {

	var want byte = 100
	got := add(11, 111)

	if want != got {
		t.Errorf("want %d, got %d", want, got)
	}
}

func TestMult(t *testing.T) {

	var want byte = 35
	got := mult(240, 120)

	if want != got {
		t.Errorf("want %d, got %d", want, got)
	}
}

func TestDiv(t *testing.T) {

	var want byte = 62
	got := div(240, 250)

	if want != got {
		t.Errorf("want %d, got %d", want, got)
	}
}

func TestInv(t *testing.T) {
	var want byte = 136
	got := inv(155)

	if want != got {
		t.Errorf("want %d, got %d", want, got)
	}
}
