import * as crypto from 'crypto'

let done = false
let i = 0

while (!done) {
	const hasher = crypto.createHash('sha256')
	const word = "Tx" + i

	if (hasher.digest(word) < (2 ** 64)) {
		console.log("Done in ", i)
		done = true
		break
	}
	else {
		console.log("nope", i)
	}

	i++
}