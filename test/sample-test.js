const { expect, util } = require('chai');
const hardhat = require('hardhat');
const { provider, utils } = hardhat.ethers;

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

  });
});

