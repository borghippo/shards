package shards

func add(a, b byte) byte {
	return a ^ b
}

func mult(a, b byte) byte {
	var p byte = 0

	for i := 0; i < 8; i++ {
		p ^= a & -(b & 1)
		b >>= 1
		overflow := a >> 7
		a <<= 1
		a ^= 0x1B & -overflow
	}

	return p
}

func div(a, b byte) byte {
	return mult(a, inv(b))
}

func inv(a byte) byte {
	a2 := mult(a, a)
	a3 := mult(a, a2)
	a6 := mult(a3, a3)
	a12 := mult(a6, a6)
	a15 := mult(a12, a3)
	a30 := mult(a15, a15)
	a60 := mult(a30, a30)
	a120 := mult(a60, a60)
	a126 := mult(a120, a6)
	a127 := mult(a126, a)
	a254 := mult(a127, a127)

	return a254
}
