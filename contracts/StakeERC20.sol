//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "../interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//import "./matic.sol";
//import "./Dux.sol";

contract StakeERC20 is ReentrancyGuard, Ownable, Pausable {
    using SafeMath for uint256;

    AggregatorV3Interface internal TokenPriceFeed;
    uint256 public rewardFactor = 1; // 1 = 1 per cent
    uint256 public rewardInterval = 86400/24/60; // 86400 = 1 day
    uint256 public duxPrice = 25 ; // DUX price 
    
    IERC20 public link; 
    IERC20 public dux; 
    
    struct StakedToken {
        uint256 amount;
        uint256 startTimestamp;
    }

    mapping(address => StakedToken) public stakedTokens; // owner => StakedToken
    mapping(address => uint256) public accruedReward;

    constructor(

    ) {
    // price feed ETHER / USD rinkeby
      TokenPriceFeed = AggregatorV3Interface(
            0xd8bD0a1cB028a31AA859A21A3758685a95dE4623
        );
         link = IERC20(0x01BE23585060835E02B77ef475b0Cc51aA1e0709);
         dux   = IERC20(0x1f42e40BC1cA24609200cf6Eae2e9662FfE35869);   
    }

   function stake(uint256 _amount) public {
        require(link.balanceOf(msg.sender) >= _amount, "You don't own this amount of matic.");
        if(stakedTokens[msg.sender].amount > 0){
            incrementAccruedReward(msg.sender);
        }
        link.transferFrom(msg.sender, address(this), _amount * 1e18);
        stakedTokens[msg.sender] = StakedToken(stakedTokens[msg.sender].amount + (_amount  * 1e18), block.timestamp);
   }

   function calculateReward(address _owner) public view returns (uint256){
        StakedToken memory staked = stakedTokens[_owner];
        uint256 rewardPriceUsd = ((staked.amount * (getLatestEthPrice() / 1e8))  * rewardFactor * (block.timestamp - staked.startTimestamp)) / 100 / rewardInterval;
        return rewardPriceUsd / duxPrice / 100;                   
   }

    function incrementAccruedReward(address _owner) internal {
        uint256 reward = calculateReward(_owner);
        StakedToken memory staked = stakedTokens[_owner];
        staked.startTimestamp = block.timestamp;
        accruedReward[_owner] += reward;
   }

    function withdraw() private {
        StakedToken memory staked = stakedTokens[msg.sender];
        incrementAccruedReward(msg.sender);
        link.transfer(msg.sender, staked.amount);
   }

    function getRewards() public {
        withdraw();
        uint256 rewards = accruedReward[msg.sender];
        dux.transfer(msg.sender, rewards);
        stakedTokens[msg.sender].amount = 0;
        stakedTokens[msg.sender].startTimestamp = 0;
        accruedReward[msg.sender] = 0;
    }

 function getLatestEthPrice() public view returns (uint256 latestTokenPrice) {
        (, int256 price, , , ) = TokenPriceFeed.latestRoundData();
        latestTokenPrice = uint256(price);
    }
}