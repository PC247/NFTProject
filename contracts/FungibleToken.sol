pragma solidity ^0.8.0;

import "./ERC20Mintable.sol";

contract FungibleToken is ERC20Mintable{
    constructor(string memory name, string memory symbol) ERC20Mintable(name, symbol) {
        
    }
}

