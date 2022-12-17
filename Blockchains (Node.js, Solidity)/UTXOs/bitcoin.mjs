import * as btc from './bitcoin-crypto.mjs'

//////////////
// Accounts //
//////////////

// Alice
const [ privkeyA, pubkeyA ] = btc.generateKeypair()
// Bob
const [ privkeyB, pubkeyB ] = btc.generateKeypair()
// Carlos
const [ privkeyC, pubkeyC ] = btc.generateKeypair()
// Denise
const [ privkeyD, pubkeyD ] = btc.generateKeypair()

///////////////////////
// Transaction Store //
///////////////////////

class Store {
	constructor() {
		this.txMap = new Map()
	}

	insert(tx) {
		this.txMap.set(tx.id, tx)

		console.log("Accepted:", this.verify(tx))
	}

	verify(tx) {
	}
}

//////////////////
// Transactions //
//////////////////

// Transaction store
let txStore = new Store()

// Genesis
let tx_genesis = {
	id: 0,
	vin: [],
	vout: [
		{
			value: 100,
			pubkey: pubkeyA
		}
	]
}

txStore.insert(tx_genesis)

// Alice: give 25 to Bob and Carlos
let in1 = {
	id: 0,
	offset: 0, // index in output vector
	value: 50,
	signature: 0
}

in1.signature = btc.signMessage(privkeyA, in1)

let tx1 = {
	id: 1,
	vin: [
		in1
	],
	vout: [
		{
			value: 25,
			pubkey: pubkeyB
		},
		{
			value: 25,
			pubkey: pubkeyC
		}
	]
}

txStore.insert(tx1)

// Carlos: give 15 to Denise
let in2 = {
	id: 1,
	offset: 1,
	value: 15,
	signature: 0
}

in2.signature = btc.signMessage(privkeyC, in2)

let tx2 = {
	id: 2,
	vin: [
		in2
	],
	vout: [
		{
			value: 15,
			pubkey: pubkeyD
		},
		{
			value: 10,
			pubkey: pubkeyC
		}
	]
}

txStore.insert(tx2)