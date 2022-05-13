const { expect, util } = require('chai');
const hardhat = require('hardhat');
const { provider, utils } = hardhat.ethers;
<<<<<<< HEAD

describe("Greeter", function () {

  let _fakeDux;
  let _fakeMatic;
  let _stakeERC20;
  let accounts;
  let _stakeContract;
  let _result;
  let revenueAddress;
  let wallet;


  beforeEach(async () => {

      // Get accounts
      accounts = await hardhat.ethers.provider.listAccounts();
      revenueAddress = accounts[0];
      wallet = accounts[1];
  

    const fakeDux = await hardhat.ethers.getContractFactory(
      'TestERC20',
    );
    const tokeFakeDux = await fakeDux.deploy();
    await tokeFakeDux.deployed();
    _fakeDux = tokeFakeDux;


  const fakeMatic = await hardhat.ethers.getContractFactory(
    'FMATICERC20',
  );
  const tokeFakeMatic = await fakeMatic.deploy();
  await tokeFakeMatic.deployed();
  _fakeMatic = tokeFakeMatic;
  

  const stakeERC20 = await hardhat.ethers.getContractFactory(
    'StakeERC20',
  );
  const stakeERC20Contract = await stakeERC20.deploy(1);
  await stakeERC20Contract.deployed();
  _stakeERC20 = stakeERC20Contract;

  //contract approvals
  _stakeContract =  _stakeERC20.address


    await _fakeDux.approve(_stakeContract, 100)
    await _fakeDux.transfer(_stakeContract, 50)

    let wei = utils.parseEther('100000');

    await _fakeMatic.approve(_stakeContract, wei)

    //account[1] approvals
    await  _fakeMatic.approve(revenueAddress, 100)
    await  _fakeMatic.transfer(revenueAddress, 100)
   

});



  it("Should return fake dux name", async function () {

    console.log(await _fakeDux.name());
  });


  it("Should return fake matic", async function () {

    console.log(await _fakeMatic.name());
  });



  it("Should return fake reward", async function () {

    console.log(await _fakeDux.balanceOf(_stakeContract));

  });


  it("Should return calculate reward", async function () {

   // console.log (await _fakeMatic.balanceOf(revenueAddress));

    await _stakeERC20.stake(100, _fakeMatic.address);

     await new Promise(resolve => setTimeout(resolve, 5000));

     _result = await  _stakeERC20.calculateReward(revenueAddress);

      console.log(_result);
=======

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

>>>>>>> 8c7a10c20e742123b3c4ceb67100167ce49ff324

  });

  // it("Should dux Token", async function () {

  //   console.log('duxToken')
  //   console.log( await _tokenDux.name());

  //   });


});

