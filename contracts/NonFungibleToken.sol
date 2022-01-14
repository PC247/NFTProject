pragma solidity ^0.8.0;

import "./ERC721MintableBurnable.sol";

contract NonFungibleToken is ERC721MintableBurnable{
    event NFTMinted(address _to, uint256 _id);

    event ProbaUpdated(uint256 _id, uint256 _proba);
    event RewardUpdated(uint256 _id, uint256 _reward);
    event CountUpdated(uint256 _id, uint256 _count);

    struct NFT{
        uint256 id;// overkill ?

        uint256 rank;
        uint256 _type;

        uint256 reward;
        uint256 probability;

        uint256 claimCount;
    }

    uint256 constant initialProbability = 90;

    mapping (uint256 => NFT) tokenIdToNFT;
    
    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI
    ) ERC721MintableBurnable(name, symbol, baseTokenURI) {}


    //GETTERS

    function getNftProba(uint256 tokenId) public view returns(uint256){
        return tokenIdToNFT[tokenId].probability;
    }

    function getNftReward(uint256 tokenId) public view returns(uint256){
        return tokenIdToNFT[tokenId].reward;
    }

    function getNftCount(uint256 tokenId) public view returns(uint256){
        return tokenIdToNFT[tokenId].claimCount;
    }

    function getNftRank(uint256 tokenId) public view returns(uint256){
        return tokenIdToNFT[tokenId].rank;
    }

    function getNftType(uint256 tokenId) public view returns(uint256){
        return tokenIdToNFT[tokenId]._type;
    }


    //SETTERS

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

    function updateNftCount(uint256 tokenId) public onlyRole(MINTER_ROLE) returns(bool){
        uint256 count = tokenIdToNFT[tokenId].claimCount++;
        emit CountUpdated(tokenId, count);
        return true;
    }


    //MINT

    function mint(address to, uint256 rank, uint256 _type, uint256 reward) public returns(uint256) {
        uint256 tokenId = mint(to);
        tokenIdToNFT[tokenId] = NFT(tokenId, rank, _type, reward, initialProbability, 0);
        emit NFTMinted(to, tokenId);
        return tokenId;
    }
}