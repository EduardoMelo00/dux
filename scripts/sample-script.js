// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const Greeter = await hre.ethers.getContractFactory("StakeERC20");
  const greeter = await Greeter.deploy(1, 
   ['0x01BE23585060835E02B77ef475b0Cc51aA1e0709', '0xF45955C70cAC6DC6Fa1b3eDCB6B1238D3381E36F' ],
   ['0xd8bD0a1cB028a31AA859A21A3758685a95dE4623','0x7794ee502922e2b723432DDD852B3C30A911F021'], 
   ['chainlink', 'chainlink']);

  await greeter.deployed();

  console.log("DUX deployed to:", greeter.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
