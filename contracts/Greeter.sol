//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "../interfaces/AggregatorV3Interface.sol";



contract Greeter {
    string private greeting;

    AggregatorV3Interface internal TokenPriceFeed;



    constructor(string memory _greeting) {


         TokenPriceFeed = AggregatorV3Interface(
            0x7794ee502922e2b723432DDD852B3C30A911F021
        );

        console.log("Deploying a Greeter with greeting:", _greeting);
        greeting = _greeting;
    }

    function greet() public view returns (string memory) {
        return greeting;
    }

    function setGreeting(string memory _greeting) public {
        console.log("Changing greeting from '%s' to '%s'", greeting, _greeting);
        greeting = _greeting;
    }

     function getLatestEthPrice() public view returns (uint256 latestEthPrice) {
        (, int256 price, , , ) = TokenPriceFeed.latestRoundData();
        latestEthPrice = uint256(price);
    }

}
