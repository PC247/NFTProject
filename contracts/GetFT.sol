pragma solidity ^0.8.0;

import "./FungibleToken.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract GetFT is Context, Ownable{
    FungibleToken _ft;

    uint256 _tokenPerWei;
    uint nonce;

    mapping (address => bool) _freeClaimed;
    bool _freeAvailable;

    constructor(address ft, uint256 price){
        _ft = FungibleToken(ft);
        _tokenPerWei = price;
        _freeAvailable = true;
    }

    function getPriceInWei() public view returns(uint256){
        return _tokenPerWei;
    }

    function getFreeAvailable() public view returns(bool){
        return _freeAvailable;
    }

    function setFreeAvailable(bool freeAvailable) public onlyOwner {
        _freeAvailable = freeAvailable;
    }

    function claimFreeToken() public {
        if(!_freeClaimed[_msgSender()]) _ft.mint(_msgSender(), 100);
    }

    function buyTokens() public payable returns (uint256 tokenAmount) {
        require(msg.value > 0, "Send ETH to buy some tokens");

        uint256 amountToBuy = msg.value * _tokenPerWei;
        _ft.mint(_msgSender(), amountToBuy);

        return amountToBuy;
    }

    function withdraw() public onlyOwner {
        uint256 ownerBalance = address(this).balance;
        require(ownerBalance > 0, "Owner has not balance to withdraw");

        (bool sent,) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send user balance back to the owner");
    }
}