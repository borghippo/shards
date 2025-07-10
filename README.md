# Shards 🧩

Shards is a library for [secret sharing](https://en.wikipedia.org/wiki/Secret_sharing) using [Shamir's secret sharing](https://en.wikipedia.org/wiki/Shamir%27s_secret_sharing) algorithm.

This implementation uses $GF(2^8)$ arithmetic allowing each byte of a secret to be represented as a polynomial (inspired by [Vault's](https://github.com/hashicorp/vault) implementation). The maximum number of shares allowed for a secret is 255 due to the size of the field.

## Example

```odin
package main

import "shards"

main :: proc() {
  secret := "the owls are not what they seem"
  threshold := 3
  parts := 4

  // splits secret into shares with given threshold for recovery
  shares, split_err := shards.split(transmute([]u8)secret, parts, threshold)

  // recovers secret given at least threshold shares
  recovered_secret, recover_err := shards.recover(shares[:threshold]) 
}
```

