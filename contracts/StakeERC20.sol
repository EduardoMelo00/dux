//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "../interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract StakeERC20 is ReentrancyGuard, Ownable, Pausable {
    using SafeMath for uint256;

    AggregatorV3Interface internal LinkPriceFeed;
    AggregatorV3Interface internal FMaticPriceFeed;

    AggregatorV3Interface internal tokenPriceFeed;
    
    uint256 public rewardFactor; // 1 = 1 per cent
    uint256 public rewardInterval = 86400/24/60; // 86400 = 1 day
    uint256 public duxPrice = 25 ; // DUX price 
    uint256 public totalSupply = 1406250;
    uint256 public lastfeedprice = 123456;
    IERC20 public _token;

    IERC20 public dux; 


    struct StakedToken {
        uint256 amount;
        IERC20 token;
        uint256 startTimestamp;
    }

    struct Pools{
        IERC20 token;
        AggregatorV3Interface oracle;
        string oracleProvider;
    }


    mapping(uint256 => Pools) public _tokensF ;
    mapping(address => mapping(uint256 => StakedToken)) public stakedTokens; // owner => StakedToken
    mapping(address => mapping(uint256 => uint256)) public accruedReward;

   //allPools
   uint256[] public allPools;


    constructor(

         uint256 _rewardFactor,
         IERC20[] memory tokensPool,
         AggregatorV3Interface[] memory oracleContract,
         string[] memory oracleProvider

    ) {

        for (uint256 index = 0; index < tokensPool.length; index++) {
            _tokensF[index].token = tokensPool[index];
            _tokensF[index].oracleProvider = oracleProvider[index];
            _tokensF[index].oracle = oracleContract[index];
            allPools.push(index);
        }

         dux   = IERC20(0x1f42e40BC1cA24609200cf6Eae2e9662FfE35869);   
         rewardFactor = _rewardFactor;
    }

   function stake(uint256 _amount, uint256 tokenIndex) public {
       require(_tokensF[tokenIndex].token.balanceOf(msg.sender) >= _amount, "You don't own this amount of matic.");
        if(stakedTokens[msg.sender][tokenIndex].amount > 0){
            incrementAccruedReward(msg.sender,tokenIndex);
        }
        
        _tokensF[tokenIndex].token.transferFrom(msg.sender, address(this), _amount * 1e18);
        stakedTokens[msg.sender][tokenIndex] = StakedToken(stakedTokens[msg.sender][tokenIndex].amount + (_amount  * 1e18), _tokensF[tokenIndex].token, block.timestamp);

   }


   function calculateReward(address _owner, uint256 tokenIndex, AggregatorV3Interface _tokenPriceFeed) public  view returns (uint256) {
       
        StakedToken memory staked = stakedTokens[_owner][tokenIndex];
        uint256 rewardPriceUsd = (staked.amount * getLatestEthPrice(_tokenPriceFeed) / 1e8 * rewardFactor * (block.timestamp - staked.startTimestamp)) / 100 / rewardInterval;
        return rewardPriceUsd / duxPrice / 100;                   
   }
   

    function incrementAccruedReward(address _owner, uint256 tokenIndex) internal {

        tokenPriceFeed = _tokensF[tokenIndex].oracle;

        uint256 reward = calculateReward(_owner,tokenIndex, tokenPriceFeed );
        StakedToken memory staked = stakedTokens[_owner][tokenIndex];
        staked.startTimestamp = block.timestamp;
        accruedReward[_owner][tokenIndex] += reward;
   }

    function withdraw(uint256 tokenIndex) private {             

        incrementAccruedReward(msg.sender, tokenIndex);

   }

    function getRewards(uint256 tokenIndex) public {
        withdraw(tokenIndex);
        uint256 rewards = accruedReward[msg.sender][tokenIndex];
        dux.transfer(msg.sender, rewards);
        stakedTokens[msg.sender][tokenIndex].startTimestamp = block.timestamp;
        accruedReward[msg.sender][tokenIndex] = 0;  
    }

     function unstake(uint256 tokenIndex) public {
        withdraw(tokenIndex);
        StakedToken memory staked = stakedTokens[msg.sender][tokenIndex];
        uint256 rewards = accruedReward[msg.sender][tokenIndex];
        dux.transfer(msg.sender, rewards);
        stakedTokens[msg.sender][tokenIndex].amount = 0;
        stakedTokens[msg.sender][tokenIndex].startTimestamp = 0;
        accruedReward[msg.sender][tokenIndex] = 0;
        _tokensF[tokenIndex].token.transfer(msg.sender, staked.amount);
    }

    function getLatestEthPrice(AggregatorV3Interface _tokenPriceFeed ) public view returns (uint256 latestTokenPrice) {

        (, int256 price, , , ) = _tokenPriceFeed.latestRoundData();
        
        latestTokenPrice = uint256(price);

        return latestTokenPrice;
    }

    function setrewardFactor(uint256 _rewardFactor) public {

            rewardFactor = _rewardFactor;
    }


    function getTokenPriceFeed() public view returns (AggregatorV3Interface) {
        return tokenPriceFeed;
    }

    function addnewPool(IERC20 newToken, AggregatorV3Interface  oracle, string memory poolOrContract ) public  {

        uint256 _newIndex = getAllPools() + 1; 
        _tokensF[_newIndex].token = newToken;
        _tokensF[_newIndex].oracle = oracle;
        _tokensF[_newIndex].oracleProvider = poolOrContract;
        allPools.push(_newIndex);
    }

    function getAllPools() public view returns(uint256) {
        return allPools.length - 1;
    }

    function getTokensF(uint256 tokenNumber) public view returns(IERC20) {

        return _tokensF[tokenNumber].token;

    }   

}