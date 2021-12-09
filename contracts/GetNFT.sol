pragma solidity ^0.8.0;

import "./FungibleToken.sol";
import "./NonFungibleToken.sol";
import "@openzeppelin/contracts/utils/Context.sol";


contract GetNFT is Context{

    FungibleToken _ft;
    NonFungibleToken _nft;

    uint256 _price;

    constructor(address ft, address nft, uint256 price){
        _ft = FungibleToken(ft);
        _nft = NonFungibleToken(nft);
        _price = price;
    }

    function claimNFT() public returns(uint256){
        require(_ft.balanceOf(_msgSender()) >= _price, "GetNFT: Unsuficient funds");
        require(_ft.allowance(_msgSender(), address(this)) >= _price, "GetNFT: Transfer payment was not approved. You must Approve transfer before claiming NFT");
        require(_ft.transferFrom(_msgSender(), address(this), _price), "GetNFT: Transfer payment Failed");
        return _nft.mint(_msgSender());// add random genes later
    }
}