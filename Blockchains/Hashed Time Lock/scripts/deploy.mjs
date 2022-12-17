import * as ethers from 'ethers';

import * as blockchainInterface from '../blockchainInterface.mjs';

const PROVIDER = "http://127.0.0.1:8545/";

// Deploy contracts

// JSON RPC endpoint of a node
let provider = blockchainInterface.getProvider(PROVIDER);

// The second parameter immediately connects the wallet to provider
let wallet0 = new ethers.Wallet("0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80", provider);
let wallet1 = new ethers.Wallet("0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d", provider);

let contractJson;
let receipt;

contractJson = blockchainInterface.readJSON("./artifacts/contracts/CoinA.sol/CoinA.json");
let CoinA = new ethers.ContractFactory(contractJson.abi, contractJson.bytecode, wallet0);
        // Using Bob's address because they're offering coinA
let coinA = await CoinA.deploy(wallet1.address);
// Wait until the transaction is mined and gets the receipt
receipt  = await coinA.deployTransaction.wait();
console.log(receipt);
                                                            
contractJson = blockchainInterface.readJSON("./artifacts/contracts/CoinB.sol/CoinB.json");
let CoinB = new ethers.ContractFactory(contractJson.abi, contractJson.bytecode, wallet0);
        // Using Alice's address because they're offering coinB
let coinB = await CoinB.deploy(wallet0.address);
// Wait until the transaction is mined and gets the receipt
receipt  = await coinB.deployTransaction.wait();
console.log(receipt);

contractJson = blockchainInterface.readJSON("./artifacts/contracts/WrappedETH.sol/WrappedETH.json");
let WrappedETH = new ethers.ContractFactory(contractJson.abi, contractJson.bytecode, wallet0);
let wrappedETH = await WrappedETH.deploy();
// Wait until the transaction is mined and gets the receipt
receipt  = await wrappedETH.deployTransaction.wait();
console.log(receipt);


contractJson = blockchainInterface.readJSON("./artifacts/contracts/Escrow.sol/Escrow.json");
let EscrowA = new ethers.ContractFactory(contractJson.abi, contractJson.bytecode, wallet0);
let escrowA = await EscrowA.deploy();//(coinA.address);
// Wait until the transaction is mined and gets the receipt
receipt  = await escrowA.deployTransaction.wait();
console.log(receipt);

contractJson = blockchainInterface.readJSON("./artifacts/contracts/Escrow.sol/Escrow.json");
let EscrowB = new ethers.ContractFactory(contractJson.abi, contractJson.bytecode, wallet1);
let escrowB = await EscrowB.deploy();
// Wait until the transaction is mined and gets the receipt
receipt  = await escrowB.deployTransaction.wait();
console.log(receipt);

console.log("const COIN_A_ADDRESS = \"" + coinA.address + "\";");
console.log("const COIN_B_ADDRESS = \"" + coinB.address + "\";");
console.log("const WRAPPED_ETH_ADDRESS = \"" + wrappedETH.address + "\";");
console.log("const ESCROW_A_ADDRESS = \"" + escrowA.address + "\";");
console.log("const ESCROW_B_ADDRESS = \"" + escrowB.address + "\";");