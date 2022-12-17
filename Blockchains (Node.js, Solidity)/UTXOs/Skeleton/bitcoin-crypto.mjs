// Documentation in https://nodejs.org/api/crypto.htm
import * as crypto from 'crypto'

// Documentation in https://github.com/cryptocoinjs/secp256k1-node
// Does not export default functions, import the whole module (welcome to JS' import hell)
import secp256k1 from 'secp256k1'

function generateKeypair() {
	let privkey = crypto.randomBytes(32)

	// Make sure you don't get special values that are invalid as private keys
	while (!secp256k1.privateKeyVerify(privkey)) {
		privkey = crypto.randomBytes(32)
	}

	let pubkey = secp256k1.publicKeyCreate(privkey)

	return [privkey, pubkey]
}

function hash(thing) {
	const hasher = crypto.createHash('sha256')

	const thingString = JSON.stringify(thing)

	return hasher.digest(thingString)
}

function signHash(privkey, hashedMessage) {
	const signatureObject = secp256k1.ecdsaSign(hashedMessage, privkey)

	return signatureObject
}

function signMessage(privkey, message) {
	const hashedMessage = hash(message)

	const signatureObject = secp256k1.ecdsaSign(hashedMessage, privkey)

	return signatureObject
}

function verifySignatureHash(pubkey, signatureObject, hashedMessage) {
	return secp256k1.ecdsaVerify(signatureObject.signature, hashedMessage, pubkey)
}

function verifySignatureMessage(pubkey, signatureObject, message) {
	const hashedMessage = hash(message)

	return secp256k1.ecdsaVerify(signatureObject.signature, hashedMessage, pubkey)
}

export {
	generateKeypair,
	hash,
	signHash,
	signMessage,
	verifySignatureHash,
	verifySignatureMessage
}

function test() {
	let [privkey, pubkey] = generateKeypair()

	let hashedMessage = hash("TS")
	let signatureObject = signHash(privkey, hashedMessage)

	let verifyResult1 = verifySignatureHash(pubkey, signatureObject, hashedMessage)
	console.log("Verification result: ", verifyResult1)

	let verifyResult2 = verifySignatureMessage(pubkey, signatureObject, "TS")
	console.log("Verification result: ", verifyResult2)
}