pragma solidity ^0.8.0;

import "./ERC721MintableBurnable.sol";

contract NonFungibleToken is ERC721MintableBurnable{
    event NFTMinted(address _to, uint256 _id);
    event ProbaUpdated(uint256 _id, uint256 _proba);
    event RewardUpdated(uint256 _id, uint256 _reward);

    struct NFT{
        uint256 reward;
        uint256 probability;
    }

    mapping (uint256 => NFT) tokenIdToNFT;
    
    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI
    ) ERC721MintableBurnable(name, symbol, baseTokenURI) {

    }

    function getNftProba(uint256 tokenId) public view returns(uint256){
        return tokenIdToNFT[tokenId].probability;
    }

    function getNftReward(uint256 tokenId) public view returns(uint256){
        return tokenIdToNFT[tokenId].reward;
    }

    function updateNftProba(uint256 tokenId, uint256 newProba) public onlyRole(MINTER_ROLE) returns(bool){
        tokenIdToNFT[tokenId].probability = newProba;
        emit ProbaUpdated(tokenId, newProba);
        return true;
    }

    function updateNftReward(uint256 tokenId, uint256 newReward) public onlyRole(MINTER_ROLE) returns(bool){
        tokenIdToNFT[tokenId].reward = newReward;
        emit RewardUpdated(tokenId, newReward);
        return true;
    }

    function mint(address to) public override returns(uint256) {
        uint256 tokenId = super.mint(to);
        tokenIdToNFT[tokenId] = NFT(1,50);// !! TEMPORARY HARD CODED VALUES
        emit NFTMinted(to, tokenId);
        return tokenId;
    }
}