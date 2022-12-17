import { program } from 'commander';

import * as ethers from 'ethers';

import * as blockchainInterface from './blockchainInterface.mjs';

import { assert } from 'chai';

const PROVIDER = "http://127.0.0.1:8545/";

const COIN_A_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
const COIN_B_ADDRESS = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
const WRAPPED_ETH_ADDRESS = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";
const ESCROW_A_ADDRESS = "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9";
const ESCROW_B_ADDRESS = "0x8464135c8F25Da09e49BC8782676a84730C318bC";

let provider = blockchainInterface.getProvider(PROVIDER);
let contractJson;

contractJson = blockchainInterface.readJSON("./artifacts/contracts/CoinA.sol/CoinA.json");
let coinA = blockchainInterface.getContract(provider, COIN_A_ADDRESS, contractJson.abi);

contractJson = blockchainInterface.readJSON("./artifacts/contracts/CoinB.sol/CoinB.json");
let coinB = blockchainInterface.getContract(provider, COIN_B_ADDRESS, contractJson.abi);

contractJson = blockchainInterface.readJSON("./artifacts/contracts/WrappedETH.sol/WrappedETH.json");
let wrappedETH = blockchainInterface.getContract(provider, WRAPPED_ETH_ADDRESS, contractJson.abi);

contractJson = blockchainInterface.readJSON("./artifacts/contracts/Escrow.sol/Escrow.json");
let escrowA = blockchainInterface.getContract(provider, ESCROW_A_ADDRESS, contractJson.abi);

contractJson = blockchainInterface.readJSON("./artifacts/contracts/Escrow.sol/Escrow.json");
let escrowB = blockchainInterface.getContract(provider, ESCROW_B_ADDRESS, contractJson.abi);

// You can create a Wallet from a private key
// let wallet = new ethers.Wallet("0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80");

// You can create a Wallet by asking for a private key if you blockchain is a local development network
let wallet0 = provider.getSigner(0);
let walletAddress0 = await wallet0.getAddress();

let wallet1 = provider.getSigner(1);
let walletAddress1 = await wallet1.getAddress();

async function logBalances(_headline) {
	let coinB_A = await coinB.balanceOf(walletAddress0);
	let coinA_B = await coinA.balanceOf(walletAddress1);
	let coinA_A = await coinA.balanceOf(walletAddress0);
	let coinB_B = await coinB.balanceOf(walletAddress1);
	let coinA_escrowA = await coinA.balanceOf(ESCROW_A_ADDRESS);
	let coinB_escrowB = await coinB.balanceOf(ESCROW_B_ADDRESS);
	let coinB_escrowA = await coinB.balanceOf(ESCROW_A_ADDRESS);
	let coinA_escrowB = await coinA.balanceOf(ESCROW_B_ADDRESS);
	console.log(_headline);
	console.log("Holder    Token    Amount");
	console.log(" ------------------------");
	console.log("Alice     Coin A    %s", coinA_A);
	console.log("Alice     Coin B    %s", coinB_A);
	console.log("Bob       Coin A    %s", coinA_B);
	console.log("Bob       Coin B    %s", coinB_B);
	console.log("ESW A     Coin A    %s", coinA_escrowA);
	console.log("ESW A     Coin B    %s", coinB_escrowA);
	console.log("ESW B     Coin A    %s", coinA_escrowB);
	console.log("ESW B     Coin B    %s", coinB_escrowB);
	console.log(" ------------------------");
}

async function test1(){
	testCase(true, true);
}
async function test2(){
	testCase(false, true);
}
async function test3(){
	testCase(true, false);
}
async function testCase(aliceEscrows, bobEscrows) {
	console.log("Alice escrows: %s", aliceEscrows);
	console.log("Bob escrows: %s", bobEscrows);
	let result
	let events
	let bytes = ethers.utils.toUtf8Bytes("Panda");
	let hashImageA = ethers.utils.sha256(bytes);


	// Alice approves their escrow to withdraw 1000 coinB
	result = await coinB.connect(wallet0).approve(ESCROW_A_ADDRESS, BigInt(1000));
	// Bob approves their escrow to withdraw 1000 coinA
	result = await coinA.connect(wallet1).approve(ESCROW_B_ADDRESS, BigInt(1000));

	assert(await coinB.allowance(walletAddress0, ESCROW_A_ADDRESS) == BigInt(1000));
	assert(await coinA.allowance(walletAddress1, ESCROW_B_ADDRESS) == BigInt(1000));
	
	await logBalances("Start");


	// Alice deposits their fine
	let result1 = await escrowA.connect(wallet0).depositFine(COIN_B_ADDRESS, BigInt(2), 2, walletAddress1);
	
	// Bob deposits their fine
	let result2 = await escrowB.connect(wallet1).depositFine(COIN_A_ADDRESS, BigInt(1), 1, walletAddress0);
	await logBalances("Fines Deposited");

	// A - Alice escrows
	if (aliceEscrows){
		result = await escrowA.connect(wallet0).escrow(COIN_B_ADDRESS, 10, hashImageA, 2) /// ..., hashImage
	}
	else {
		await logBalances("Alice didn't escrow");
		// Bob withdraws their fines from Alice's account
		result = await escrowA.connect(wallet1).payoutFine(); // pA + pB -> Bob

		// Alice withdraws their fines from Bob's account
		result = await escrowB.connect(wallet0).payoutFine(); // pB -> Alice
		
		await logBalances("Fine Payout");

		// End the protocol
		console.log("Alice didn't escrow");
		return
	}
	events = await escrowA.queryFilter("Escrowed");
	
	// Make sure that there's more than one event generated
	assert(events.length > 0)

	// Make sure that the last Escrow event generated contains three elements
	assert(events[events.length - 1].args.length == 3)
	await logBalances("Alice Escrows");
	

	// The hash image should be the first element of the event above.
	let hashImageB = events[events.length-1].args[0]._hex;
	// let x = 1;
	// let img = hashImageB
	// B - Bob escrows, using the hashImage above
	if (bobEscrows){
		result = await escrowB.connect(wallet1).escrow(COIN_A_ADDRESS, 15, hashImageB, 1);
	}
	else {
		await logBalances("Bob didn't escrow");

		// Alice withdraws their escrow after bob misses the deadline
		result = await escrowA.connect(wallet0).withdrawEscrow();
		// Alice withdraws their fines from Bob's account
		result = await escrowB.connect(wallet0).payoutFine(); // pB -> Alice
		

		await logBalances("Fine Payout");

		// End the protocol
		console.log("Bob didn't escrow");
		return
	}

	events = await escrowB.queryFilter("Escrowed");

	// Make sure that there's more than one event generated
	assert(events.length > 0)

	// Make sure that the last Escrow event generated contains three elements
	assert(events[events.length - 1].args.length == 3)
	await logBalances("Bob Escrows");
	

	// C - Alice withdraws
	// Note that Alice is connecting to Bob's contract
	result = await escrowB.connect(wallet0).receiveEscrow("Panda")

	events = await escrowB.queryFilter("Withdrawn")

	// Make sure that there's more than one event generated
	assert(events.length > 0)

	// Make sure that the last Withdraw event generated contains three elements
	assert(events[events.length - 1].args.length == 4)
	await logBalances("Alice Withdraws");

	// The hash image should be the first element of the event above.
	let hashPreimage = events[events.length - 1].args[0];

	// D - Bob withdraws
	// Note that Bob is connecting to Alice's contract
	result = await escrowA.connect(wallet1).receiveEscrow(hashPreimage);

	events = await escrowA.queryFilter("Withdrawn")

	// Make sure that there's more than one event generated
	assert(events.length > 0)

	// Make sure that the last Withdraw event generated contains three elements
	assert(events[events.length - 1].args.length == 4)
	await logBalances("Bob Withdraws");
}

async function main() {
	program.option("-r, --rpc", "Node RPC endpoint", "'http://localhost:8545");

	program
		.command("test1")
		.action(test1) //testCase(true, true);

	program
		.command("test2")
		.action(test2) //testCase(false, true);

	program
		.command("test3")
		.action(test3) //testCase(true, false);

	await program.parseAsync();
}

await main();