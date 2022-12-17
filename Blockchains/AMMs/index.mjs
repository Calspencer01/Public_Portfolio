import { program } from 'commander';

import * as ethers from 'ethers';

import * as blockchainInterface from './blockchainInterface.mjs';

import { assert } from 'chai';

const PROVIDER = "http://127.0.0.1:8545/";

const TEST_TOKEN_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
const WRAPPED_ETH_ADDRESS = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
const AMM_ADDRESS = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";

let provider = blockchainInterface.getProvider(PROVIDER);
let contractJson;

contractJson = blockchainInterface.readJSON("./artifacts/contracts/TestToken.sol/TestToken.json");
let testToken = blockchainInterface.getContract(provider, TEST_TOKEN_ADDRESS, contractJson.abi);

contractJson = blockchainInterface.readJSON("./artifacts/contracts/WrappedETH.sol/WrappedETH.json");
let wrappedETH = blockchainInterface.getContract(provider, WRAPPED_ETH_ADDRESS, contractJson.abi);

contractJson = blockchainInterface.readJSON("./artifacts/contracts/AMM.sol/AMM.json");
let amm = blockchainInterface.getContract(provider, AMM_ADDRESS, contractJson.abi);
// You can create a Wallet from a private key
// let wallet = new ethers.Wallet("0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80");

// You can create a Wallet by asking for a private key if you blockchain is a local development network
let wallet = provider.getSigner(0);
let walletAddress = await wallet.getAddress()


function getDirection(directionString) {
	if(directionString.toLowerCase() == "f" || directionString.toLowerCase() == "forward") {
		return FirstToSecond;
	}
	else {
		return SecondToFirst;
	}
}

async function createSwapper(addressToken1, value1, addressToken2, value2) {
	let result = await amm.connect(wallet).createSwapper(addressToken1, value1, addressToken2, value2);
	let mined = await result.wait();

	console.log(result);
	console.log(mined);
}

async function createNativeSwapper(addressToken1, value1) {
	let result = await amm.connect(wallet).createNativeSwapper(addressToken1, value1);
	let mined = await result.wait();

	console.log(result);
	console.log(mined);
}

async function swap(swapperId, amount, direction) {
	let result = await amm.connect(wallet).swap(swapperId, amount, getDirection(direction));
	let mined = await result.wait();
	
	console.log(result);
	console.log(mined);
}

async function addLiquidity(swapperId, amount, direction) {
	let result = await amm.connect(wallet).addLiquidity(swapperId, amount, getDirection(direction));
	let mined = await result.wait();

	console.log(result);
	console.log(mined);
}

async function removeLiquidity(swapperId, amount, direction) {
	let result = await amm.connect(wallet).removeLiquidity(swapperId, amount, getDirection(direction));
	let mined = await result.wait();

	console.log(result);
	console.log(mined);
}

async function clearLiquidity(swapperId) {
	let result = await amm.connect(wallet).clearLiquidity(swapperId);
	let mined = await result.wait();

	console.log(result);
	console.log(mined);
}

async function test() {
	let result
	let events

	let oldBalanceTT
	let oldBalanceWE
	let newBalanceTT
	let newBalanceWE

	let balance

	// A - Deposit values into the wrapped token

	result = await wrappedETH.connect(wallet).deposit({ value: BigInt(1000) });

	balance = await wrappedETH.balanceOf(walletAddress);
	
	assert(balance == BigInt(1000));

	// B - Approve 10000 units of each token and check allowance
	result = await testToken.connect(wallet).approve(AMM_ADDRESS, BigInt(10000));
	result = await wrappedETH.connect(wallet).approve(AMM_ADDRESS, BigInt(10000));

	assert(await testToken.allowance(walletAddress, AMM_ADDRESS) == BigInt(10000));
	assert(await wrappedETH.allowance(walletAddress, AMM_ADDRESS) == BigInt(10000));

	// C - Create swapper should return swapper #1, check event
	oldBalanceTT = (await testToken.balanceOf(walletAddress)).toBigInt();

	result = await amm.connect(wallet).createSwapper(TEST_TOKEN_ADDRESS, BigInt(5000), WRAPPED_ETH_ADDRESS, BigInt(1000));

	events = await amm.queryFilter("SwapperCreated")
	assert(events.length > 0)
	assert(events[events.length - 1].args[0] == 1)

	// D - Should trade correctly in the forward direction

	oldBalanceTT = (await testToken.balanceOf(walletAddress)).toBigInt(); // 5000
	oldBalanceWE = (await wrappedETH.balanceOf(walletAddress)).toBigInt(); // 0

	result = await amm.connect(wallet).swap(1, BigInt(1000), 0);

	newBalanceTT = (await testToken.balanceOf(walletAddress)).toBigInt();
	newBalanceWE = (await wrappedETH.balanceOf(walletAddress)).toBigInt();

	assert(newBalanceTT == oldBalanceTT - BigInt(995)); // Lefover is 5
	assert(newBalanceWE == oldBalanceWE + BigInt(162)); // Should be 166, but 4 have been added to fees

	// E - Add liquidity, check event

	let wallet1 = provider.getSigner(1);
	let walletAddress1 = await wallet1.getAddress()

	// Setup wallet1:
	// a) Get wallet1 to buy WrappedETH
	result = await wrappedETH.connect(wallet1).deposit({ value: BigInt(1000) });
	// b) Get wallet to transfer 1000 TestTokens to wallet1
	result = await testToken.connect(wallet).transfer(walletAddress1, BigInt(1000));
	// c) Approve transfers to the amm contract on both tokens
	result = await testToken.connect(wallet1).approve(AMM_ADDRESS, BigInt(1000));
	result = await wrappedETH.connect(wallet1).approve(AMM_ADDRESS, BigInt(1000));
	
	// d) Add liquidity
	result = await amm.connect(wallet1).addLiquidity(1, BigInt(100), 0);

	events = await amm.queryFilter("LiquidityAdded")

	assert(events.length > 0);
	assert(events[events.length - 1].args[0] == 1);
	assert(events[events.length - 1].args[2] == 100);
	assert(events[events.length - 1].args[3] == 13);

	// F - Check to see if the rewards of the first wallet have been given (for the trade earlier)

	oldBalanceTT = newBalanceTT - 1000n; // From the last trade, adjusted for (b) above
	oldBalanceWE = newBalanceWE; // From the last trade
	
	newBalanceTT = (await testToken.balanceOf(walletAddress)).toBigInt();
	newBalanceWE = (await wrappedETH.balanceOf(walletAddress)).toBigInt();
	
	assert(newBalanceTT == oldBalanceTT);
	
	assert(newBalanceWE == oldBalanceWE + BigInt(4)); // Should add the 4 of the previous trade

	// G - Check if you trade correctly backward

	oldBalanceTT = (await testToken.balanceOf(walletAddress)).toBigInt();
	oldBalanceWE = (await wrappedETH.balanceOf(walletAddress)).toBigInt();

	result = await amm.connect(wallet).swap(1, BigInt(50), 1);

	newBalanceTT = (await testToken.balanceOf(walletAddress)).toBigInt();
	newBalanceWE = (await wrappedETH.balanceOf(walletAddress)).toBigInt();
    
	// If E-F commented: Should be 338, but 7 have been added to fees
	// If E-F active: Should be 339, but 7 have been added to fees (SO CHANGE IT TO 332 below)
	assert(newBalanceTT == oldBalanceTT + BigInt(332));
	// If E-F commented: leftover is 1
	// If E-F active: leftover is 1
	assert(newBalanceWE == oldBalanceWE - BigInt(49));

	let swapperId = 0;
	swapperId = (await amm.connect(wallet).getSwapper(TEST_TOKEN_ADDRESS, WRAPPED_ETH_ADDRESS));
	assert(swapperId == 1);
}

async function main() {
	program.option("-r, --rpc", "Node RPC endpoint", "'http://localhost:8545");

	program
		.command("createSwapper <addressToken1> <value1> <addressToken2> <value2>")
		.action(createSwapper);

	program
		.command("createNativeSwapper <addressToken1> <value1>")
		.action(createNativeSwapper);

	program
		.command("swap <swapperId> <amount> <direction>")
		.action(swap)

	program
		.command("addLiquidity <swapperId> <amount> <direction>")
		.action(addLiquidity)

	program
		.command("removeLiquidity <swapperId> <amount> <direction>")
		.action(removeLiquidity)

	program
		.command("clearLiquidity <swapperId>")
		.action(clearLiquidity)

	program
		.command("test")
		.action(test)

	await program.parseAsync();
}

await main();