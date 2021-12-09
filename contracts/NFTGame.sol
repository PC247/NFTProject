pragma solidity ^0.8.0;

import "./FungibleToken.sol";
import "./NonFungibleToken.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract NFTGame is Context{
    event SuccesfulClaim(uint256 _tokenId, uint _reward);
    event FailedClaim(uint256 _tokenId);

    FungibleToken _ft;
    NonFungibleToken _nft;

    uint nonce;

    constructor(address ft, address nft){
        _ft = FungibleToken(ft);
        _nft = NonFungibleToken(nft);
    }

    function pseudoRNG() public returns(uint256) {
        nonce++;
        return uint256(keccak256(abi.encodePacked(nonce, msg.sender, blockhash(block.number - 1))));
    }

    function claimReward(uint256 tokenId) public returns(uint256){
        require(_nft.ownerOf(tokenId) == _msgSender(), "NFTGame: not owner of NFT");
        require(_nft.getApproved(tokenId) == address(this), "NFTGame: NFT not approved, no NFT at stake.");

        uint256 rnd = pseudoRNG() % 100;
        uint256 proba = _nft.getNftProba(tokenId);

        if(rnd <= proba){
            uint256 newProba = proba * 9 / 10;// TEMPORARY HARD CODED VALUE
            _nft.updateNftProba(tokenId, newProba);

            uint256 reward = _nft.getNftReward(tokenId);
            _ft.mint(_msgSender(), reward);
            _nft.updateNftReward(tokenId, reward++);// TEMPORARY HARD CODED VALUE

            emit SuccesfulClaim(tokenId, reward);
            return reward;
        }
        else{
            _nft.burn(tokenId);
            emit FailedClaim(tokenId);
            return 0;
        }
    }
}