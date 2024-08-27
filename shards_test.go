package shards

import (
	"reflect"
	"testing"
)

func TestSplitAndAssemble(t *testing.T) {
	secret := []byte{'g', 'l', 'a', 's', 's'}
	threshold := 4
	parts := 6

	shares, err := Split(secret, parts, threshold)
	if err != nil {
		t.Fatal(err)
	}

	if len(shares) != int(parts) {
		t.Errorf("got %d shares, want %d", len(shares), parts)
	}

	if len(shares[0]) != len(secret)+1 {
		t.Errorf("got share length of %d, want %d", len(shares[0]), len(secret)+1)
	}

	reconstructedSecret, err := Reconstruct(shares)
	if err != nil {
		t.Fatal(err)
	}

	if !reflect.DeepEqual(reconstructedSecret, secret) {
		t.Errorf("want secret: '%s', got '%s'", reconstructedSecret, secret)
	}

}
