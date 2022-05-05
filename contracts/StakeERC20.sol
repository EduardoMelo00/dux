//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "../interfaces/AggregatorV3Interface.sol";

import "./Mana.sol";
import "./Dux.sol";

contract StakeERC20 is ReentrancyGuard, Ownable, Pausable {
    using SafeMath for uint256;

    AggregatorV3Interface internal TokenPriceFeed;
    uint256 public rewardFactor = 1; // 1 = 1 per cent
    uint256 public rewardInterval = 86400/24/60; // 86400 = 1 day


    struct StakedToken {
        uint256 amount;
        uint256 startTimestamp;
    }

    mapping(address => StakedToken) public stakedTokens; // owner => StakedToken
    mapping(address => uint256) public accruedReward;

    Mana public mana;
    Dux public dux;

    constructor(
        Mana _mana,
        Dux _dux
    ) {
        mana = _mana;
        dux = _dux;

    // price feed MATIC / USD rinkeby
      TokenPriceFeed = AggregatorV3Interface(
            0x7794ee502922e2b723432DDD852B3C30A911F021
        );
    }

   function stake(uint256 _amount) public {
        require(mana.balanceOf(msg.sender) >= _amount, "You don't own this amount of MANA.");
        if(stakedTokens[msg.sender].amount > 0){
            incrementAccruedReward(msg.sender);
        }
        mana.transferFrom(msg.sender, address(this), _amount * 1e18);
        stakedTokens[msg.sender] = StakedToken(stakedTokens[msg.sender].amount + (_amount  * 1e18), block.timestamp);
   }

   function calculateReward(address _owner) public view returns (uint256){
        StakedToken memory staked = stakedTokens[_owner];
        return (staked.amount * rewardFactor * (block.timestamp - staked.startTimestamp)) / 100 / rewardInterval;
   }

    function incrementAccruedReward(address _owner) internal {
        uint256 reward = calculateReward(_owner);
        StakedToken memory staked = stakedTokens[_owner];
        staked.startTimestamp = block.timestamp;
        accruedReward[_owner] += reward;
   }

   function withdraw() public {
        StakedToken memory staked = stakedTokens[msg.sender];
        incrementAccruedReward(msg.sender);
        mana.transferFrom(address(this), msg.sender, staked.amount);
   }

    function getRewards() public {
        withdraw();
        uint256 rewards = accruedReward[msg.sender];
        dux.transferFrom(address(this), msg.sender, rewards);
        stakedTokens[msg.sender].amount = 0;
        stakedTokens[msg.sender].startTimestamp = 0;
    }

 function getLatestEthPrice() public view returns (uint256 latestTokenPrice) {
        (, int256 price, , , ) = TokenPriceFeed.latestRoundData();
        latestTokenPrice = uint256(price);
    }
}