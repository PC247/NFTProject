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


    //PLAY THE GAME

    function pseudoRNG() public returns(uint256) {
        nonce++;
        return uint256(keccak256(abi.encodePacked(nonce, msg.sender, blockhash(block.number - 1))));
    }

    function getReward(uint hReward, uint hProbability) internal returns (uint rwrd){
        uint _reward = hReward;
        uint _risk = hProbability;

        uint rnd = pseudoRNG();
        if(rnd % 100 <= _risk) return _reward;
        else return 0;
    }

    function claimReward(uint256 tokenId) public returns(uint256){
        require(_nft.ownerOf(tokenId) == _msgSender(), "NFTGame: not owner of NFT");
        require(_nft.getApproved(tokenId) == address(this), "NFTGame: NFT not approved, no NFT at stake.");

        uint256 risk = _nft.getNftProba(tokenId);
        uint256 reward = _nft.getNftProba(tokenId);

        uint256 tokens = getReward(reward, risk);

        if(tokens == 0){
            _nft.burn(tokenId);
            emit FailedClaim(tokenId);
            return 0;
        }

        uint256 rank = _nft.getNftRank(tokenId);
        uint256 count = _nft.getNftCount(tokenId);

        tokens += rank * rank * (count/3); // rewards risk taken 

        _nft.updateNftCount(tokenId);

        risk -= risk * count * count * reward / ((10 - count) * 100); 
        _nft.updateNftProba(tokenId, risk);

        emit SuccesfulClaim(tokenId, reward);
        return reward;
    }
}