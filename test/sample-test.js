const { expect, util } = require('chai');
const hardhat = require('hardhat');
const { provider, utils } = hardhat.ethers;

describe('Campaign', function () {


let campaignFactory, campaign;
let _tokenMatic;
let _tokenDux;
let _tokenLink;
let accounts;
let revenueAddress;
let wallet;
let _stakeERC20;

beforeEach(async () => {


// Get accounts
accounts = await hardhat.ethers.provider.listAccounts();
revenueAddress = accounts[0];
wallet = accounts[1];

    // // Deploy token StakeERC20
    // const StakeERC20 = await hardhat.ethers.getContractFactory(
    //   'StakeERC20',
    // );
    // const stakeERC20 = await StakeERC20.deploy();
    // await stakeERC20.deployed();
    // _stakeERC20 = stakeERC20;

    // Deploy token FMATIC
    const TokenMatic = await hardhat.ethers.getContractFactory(
      'TestERC20',
    );
    const maticToken = await TokenMatic.deploy();
    await maticToken.deployed();
    _tokenMatic = maticToken;


    // Deploy token LINK
    const TokenLink = await hardhat.ethers.getContractFactory(
      'TestLink',
    );
    const linkToken = await TokenLink.deploy();
    await linkToken.deployed();
    _tokenLink = linkToken;


   // Deploy token DUX
    // const TokenDux = await hardhat.ethers.getContractFactory(
    //   'TestDUX',
    // );
    // const duxToken = await TokenDux.deploy();
    // await duxToken.deployed();
    // _tokenDux = duxToken;  

}); 



  it("Should return the new greeting once it's changed", async function () {

    console.log('tokenMatic')
    console.log( await _tokenMatic.name());

  });

  it("Should link Token", async function () {

    console.log('tokenLink')
    console.log( await _tokenLink.name());


  });

  // it("Should dux Token", async function () {

  //   console.log('duxToken')
  //   console.log( await _tokenDux.name());

  //   });


});
