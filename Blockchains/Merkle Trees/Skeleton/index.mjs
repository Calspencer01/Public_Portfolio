import { randomBytes  } from 'crypto';
import { buildPoseidon } from 'circomlibjs';
import { utils } from 'ffjavascript';
import fs from 'fs';

import { Wallet } from 'ethers';

import { MerkleTree } from './merkle_tree.mjs';

async function main(commitmentString, recipientString) {
	let poseidon = await buildPoseidon();

	let hasher1 = (a) => {
	  return poseidon.F.toObject(poseidon([a]));
	}

	let hasher2 = (a, b) => {
	  return poseidon.F.toObject(poseidon([a, b]));
	}

	let merkleTree = new MerkleTree(5, hasher2);

	for(var i = 0; i < 10; i++) {
		merkleTree.append(hasher1(i));
	}

	for(var i = 0; i < 10; i++) {
		let [root, siblings, isLeft] = merkleTree.getProof(i);

		console.log("Root for index %d: %d", i, root);
		console.log("Siblings:", siblings);
		console.log("isLeft:", isLeft);

		// Calculate root to confirm results of getProof()

		var running_hash = hasher1(i);
		for (var l = siblings.length-1; l >= 0 ; l--){
			if (isLeft[l]){
				running_hash = hasher2(running_hash, siblings[l]);
			}
			else {
				running_hash = hasher2(siblings[l], running_hash);
			}
			
			
		}
		if (running_hash == root){
			console.log("Confirmed");
		}
		else {
			console.log("Invalid");
		}
	}	
}

await main();