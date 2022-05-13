// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestERC20 is ERC20 {
<<<<<<< HEAD
    constructor() ERC20("FAKEDUX", "FDUX") {
        _mint(msg.sender, 100000000 * (10**uint256(decimals())));
=======
    constructor() ERC20("FAKEMATIC", "FMATIC") {
        _mint(msg.sender, 10000000 * (10**uint256(decimals())));
>>>>>>> 8c7a10c20e742123b3c4ceb67100167ce49ff324
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }
}
