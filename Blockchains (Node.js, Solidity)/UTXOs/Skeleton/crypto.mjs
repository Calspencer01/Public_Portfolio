// Documentation in https://nodejs.org/api/crypto.htm
import * as crypto from 'crypto'

// Generates random bytes

let random = crypto.randomBytes(32)

console.log(random)

// Hash

const hasher = crypto.createHash('sha256')

console.log(hasher.digest("yo"))

// Symmetric encryption
// Use "openssl list -cipher-algorithms" to see what's available locally

// Make an initialization vector of 16B (256b -- same size as required by the algorithm)
// It's OK for that to be random because you can pass the initialization vector along with your encrypted data
let iv = crypto.randomBytes(16)
let key = crypto.scryptSync('password', 'salt', 32)

// Algorithm, key, initialization vector
const symmetricCipher = crypto.createCipheriv('aes-256-cbc', key, iv)

// If you input strings, you have to provide input and output encodings otherwise they're optional (default to Buffer)
let cyphertext = symmetricCipher.update('My bank account password is TaylorSwift', 'utf8', 'hex')
cyphertext += symmetricCipher.final('hex')

let ivString = iv.toString('hex')
console.log("Encrypted:", { cyphertext, ivString })

let iv2 = Buffer.from(ivString, 'hex')
// Symmetric decription
const symmetricDecipher = crypto.createDecipheriv('aes-256-cbc', key, iv2)

// If you input strings, you have to provide input and output encodings otherwise they're optional (default to Buffer)
let plaintext = symmetricDecipher.update(cyphertext, 'hex', 'utf8')
plaintext += symmetricDecipher.final('utf8')

console.log("Decrypted:", plaintext)

// Generate public private keys

const { privateKey, publicKey } = crypto.generateKeyPairSync('ed25519')

const message = 'Is his password really TaylorSwift?'

const signature = crypto.sign(null, Buffer.from(message), privateKey)
const result = crypto.verify(null, Buffer.from(message), publicKey, signature)
console.log("Verification result:", result)
