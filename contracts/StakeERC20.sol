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

    AggregatorV3Interface internal LinkPriceFeed;
    AggregatorV3Interface internal FMaticPriceFeed;

    AggregatorV3Interface internal tokenPriceFeed;
    
    uint256 public rewardFactor; // 1 = 1 per cent
    uint256 public rewardInterval = 86400/24/60; // 86400 = 1 day
    uint256 public duxPrice = 25 ; // DUX price 
    uint256 public totalSupply = 1406250;
    uint256 public lastfeedprice = 123456;
    IERC20 public _token;

    IERC20 public link; 
    IERC20 public dux; 

    enum Tokens {
        LINK,
        MATIC
    }

    Tokens public enumToken;

    struct StakedToken {
        uint256 amount;
        IERC20 token;
        uint256 startTimestamp;
    }


    mapping(uint256 => IERC20) _tokensF ;







    mapping(address => mapping(Tokens => StakedToken)) public stakedTokens; // owner => StakedToken
    mapping(address => mapping(Tokens => uint256)) public accruedReward;
   // mapping(Tokens =>IERC20) public tokensByNumbber; 


    constructor(

         uint256 _rewardFactor,
         IERC20[] memory tokensPool

    ) {



        for (uint256 index = 0; index < tokensPool.length; index++) {

            _tokensF[index] = tokensPool[0];
            
        }

               // price feed ETHER / USD rinkeby
    //   tokenPriceFeed = AggregatorV3Interface(
    //         0xd8bD0a1cB028a31AA859A21A3758685a95dE4623
    //     );
         link = IERC20(0x01BE23585060835E02B77ef475b0Cc51aA1e0709);

         dux   = IERC20(0x1f42e40BC1cA24609200cf6Eae2e9662FfE35869);   



         rewardFactor = _rewardFactor;
    }

   function stake(uint256 _amount, IERC20 token, Tokens tokenName) public {
       require(token.balanceOf(msg.sender) >= _amount, "You don't own this amount of matic.");
        if(stakedTokens[msg.sender][tokenName].amount > 0){
            incrementAccruedReward(msg.sender,tokenName);
        }
        
        token.transferFrom(msg.sender, address(this), _amount * 1e18);
        stakedTokens[msg.sender][tokenName] = StakedToken(stakedTokens[msg.sender][tokenName].amount + (_amount  * 1e18), token, block.timestamp);

   }




   function calculateReward(address _owner, Tokens tokenName) public returns (uint256){
        StakedToken memory staked = stakedTokens[_owner][tokenName];
        uint256 rewardPriceUsd = (staked.amount * getLatestEthPrice(tokenName) / 1e8 * rewardFactor * (block.timestamp - staked.startTimestamp)) / 100 / rewardInterval;
        return rewardPriceUsd / duxPrice / 100;                   
   }
   

    function incrementAccruedReward(address _owner, Tokens tokenName) internal {
        uint256 reward = calculateReward(_owner,tokenName );
        StakedToken memory staked = stakedTokens[_owner][tokenName];
        staked.startTimestamp = block.timestamp;
        accruedReward[_owner][tokenName] += reward;
   }

    function withdraw(Tokens tokenName) private {             

        incrementAccruedReward(msg.sender, tokenName);

   }

    function getRewards(Tokens tokenName) public {
        withdraw(tokenName);
        uint256 rewards = accruedReward[msg.sender][tokenName];
        dux.transfer(msg.sender, rewards);
        stakedTokens[msg.sender][tokenName].startTimestamp = block.timestamp;
        accruedReward[msg.sender][tokenName] = 0;  
    }

     function unstake(Tokens tokenName, IERC20 token) public {
        withdraw(tokenName);
        StakedToken memory staked = stakedTokens[msg.sender][tokenName];
        uint256 rewards = accruedReward[msg.sender][tokenName];
        dux.transfer(msg.sender, rewards);
        stakedTokens[msg.sender][tokenName].amount = 0;
        stakedTokens[msg.sender][tokenName].startTimestamp = 0;
        accruedReward[msg.sender][tokenName] = 0;
        token.transfer(msg.sender, staked.amount);
    }

    function getLatestEthPrice(Tokens tokenName ) public returns (uint256 latestTokenPrice) {

         if (keccak256(abi.encodePacked(tokenName)) == keccak256(abi.encodePacked(Tokens.MATIC)) ) {
            //matic
            tokenPriceFeed = AggregatorV3Interface(0x7794ee502922e2b723432DDD852B3C30A911F021);
       } else {
            //link
            tokenPriceFeed = AggregatorV3Interface(0xd8bD0a1cB028a31AA859A21A3758685a95dE4623);
       } 
        (, int256 price, , , ) = tokenPriceFeed.latestRoundData();
        latestTokenPrice = uint256(price);
    }

    function setrewardFactor(uint256 _rewardFactor) public {

            rewardFactor = _rewardFactor;
    }


    function getTokenPriceFeed() public view returns (AggregatorV3Interface) {
        return tokenPriceFeed;
    }

    function addnewPool(IERC20 newToken, string memory oracle, string memory poolOrContract ) public  {

    }

    function getTokensF(uint256 tokenNumber) public view returns(IERC20) {


        return _tokensF[tokenNumber];

    }



}