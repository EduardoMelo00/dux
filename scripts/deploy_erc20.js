const { ethers } = require('hardhat');

async function main() {
  // We get the contract to deploy
  const CampaignFactory = await ethers.getContractFactory("FMATICERC20");
  const deployed = await CampaignFactory.deploy();

  console.log("Contract deployed to:", deployed.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });