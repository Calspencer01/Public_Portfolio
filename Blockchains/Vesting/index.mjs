import { getProvider, getContract, getSignerEmbedded } from "./blockchainInterface.mjs"
import { erc20Interface, vestingManagerInterface } from "./contractABI.mjs"

const PROVIDER = "http://127.0.0.1:8545/";

const TEST_TOKEN_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
const VESTING_MANAGER_ADDRESS = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";

// If you are connected testnet or mainnet, insert your node JSON RPC endpoint here.
// If you use Infura, there's a getProviderInfura() to help with that (mainnet or testnet).
// If you use Ganache/Hardhat, your blockchain simulator is running on localhost, but behaves
// similarly to mainnet/testnet.
let provider = getProvider(PROVIDER);

// Get accounts and addresses from ganache/hardhat
// If you are connected to mainnet/testnet, you should use getSigner() to create a wallet using mnemonics
const signer0 = getSignerEmbedded(provider, 0)
const signer1 = getSignerEmbedded(provider, 1)
const signer2 = getSignerEmbedded(provider, 2)
const signerAddress0 = await signer0.getAddress()
const signerAddress1 = await signer1.getAddress()
const signerAddress2 = await signer2.getAddress()

var testToken0
var vestingManager0

// Signer0 will own the TestToken and the VestingManager
async function connectContracts() {
  testToken0 = getContract(signer0, TEST_TOKEN_ADDRESS, erc20Interface)
  vestingManager0 = getContract(signer0, VESTING_MANAGER_ADDRESS, vestingManagerInterface)
}

// Signer0 will create the vesting schedule for signer1 and signer2
async function createVesting() {
  // 300 units in the test token are allowed for the vesting contract
  const vestingAllowance = BigInt("300000000000000000000")
  await testToken0.approve(vestingManager0.address, vestingAllowance)

  // 100 units are vested for signer1 (1 week), and 200 units are vested for signer2 (2 weeks)
  const vestingAllowance1 = BigInt("100000000000000000000")
  const vestingAllowance2 = BigInt("200000000000000000000")

  await vestingManager0.createVesting(signerAddress1, vestingAllowance1, 1)
  await vestingManager0.createVesting(signerAddress2, vestingAllowance2, 2)
}

// Signer1 will now collect the token
async function testVesting() {
  const testToken1 = getContract(signer1, testToken0.address, erc20Interface)
  const vestingManager1 = getContract(signer1, vestingManager0.address, vestingManagerInterface)

  var amountReady = await vestingManager1.ready(signerAddress1)

  var balanceBefore = await testToken1.balanceOf(signerAddress1)
  console.log("Balance before: " + balanceBefore)
  if (amountReady > 0) {
    console.log("Claiming " + amountReady + "TTKs")

    await vestingManager1.claimReady()

    var balanceAfter = await testToken1.balanceOf(signerAddress1)
                                                  
    console.log("Balance after: " + balanceAfter)
  }
  else {
    console.log("No TTKs are ready to claim")
  }
}

await connectContracts()
await createVesting()
await testVesting()
