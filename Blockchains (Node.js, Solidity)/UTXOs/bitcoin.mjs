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
		// ----- 6) Instead of printing, return whether the verification worked.
		// 			Also, only insert in the map if the verification indeed worked.
		
		// Store verification result
		let accepted = this.verify(tx)
		if (accepted){
			// Insert in map
			this.txMap.set(tx.id, tx)
			console.log("Accepted")
		} 
		else {
			// Do not insert in map
			console.log("Not Accepted")
		}
		return accepted
	}

	verify(tx) {
		// ----- 1) Install the secp256k1 package using [npm install secp256k1]
		
		let totalInput = 0
		let totalOutput = 0

		// For each input of the transaction
		for(var i = 0; i < tx.vin.length; i++) {
			let vtx = tx.vin[i]

			// ----- 2) Verify that the source UTXO exists, and that the value of the input matches the UTXO value
			
			// Break if transaction doesn't exist in txMap
			if (typeof this.txMap.get(vtx.id) == "undefined"){
				return false
			}
				
			// Store source transaction in txMap using vtx.id
			let source_tx = this.txMap.get(vtx.id)
			
			// Find in source output in vout using vtx.offset
			let source_utxo = source_tx.vout[vtx.offset]
			
			// Check if utxo is found
			if (typeof source_utxo == "undefined"){
				return false 
			} 
			
			// Compare values if utxo is not undefined
			if (source_utxo.value != vtx.value){
				// Incorrect values
				return false
			}

			// ----- 3) Zero the signature field of the copy, and verify that the signature matches
			
			// Store signature
			let signatureObject  = vtx.signature

			// Zero signature field
			vtx.signature = 0

			// Get public key of source utxo
			let pubKey = source_utxo.pubkey
			
			// Verify signature 
			let result = btc.verifySignatureMessage(pubKey, signatureObject, vtx)

			// False result if signature cannot be verified
			if (!result){
				return false
			}

			// ----- 4) Restore the signature field to the old value
			vtx.signature = signatureObject

			// Add the value of the input to the sum of all input values
			totalInput += vtx.value
		}
		// ----- 5) Verify that the sum of output UTXOs is smaller (or equal to) than the sum of the source UTXOs
		
		// For each transaction in the outputs vector
		for(var i = 0; i < tx.vout.length; i++) {
			let vtx = tx.vout[i]
			// Sum all values in output vector
			totalOutput += vtx.value
		}

		// Compare the sum of output UTXOs to the source UTXOs
		if (tx.vin.length == 0 && tx.id == 0){
			console.log("No inputs, transaction will be accepted as genesis block")
		}
		else if (totalOutput > totalInput){
			return false
		}
		

		return true
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
			value: 50,
			pubkey: pubkeyA
		}
	]
}

txStore.insert(tx_genesis)

// Alice: give 25 to Bob and Carlos
let in1 = {
	id: 0,
	offset: 0,
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
	value: 25,
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
			pubkey: pubkeyB
		},
		{
			value: 10,
			pubkey: pubkeyC
		}
	]
}

txStore.insert(tx2)