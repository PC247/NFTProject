pragma solidity ^0.8.0;

import "./FungibleToken.sol";
import "./NonFungibleToken.sol";

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract GetNFT is Context, Ownable{
    FungibleToken _ft;
    NonFungibleToken _nft;

    struct Pack{
        uint256 _id;
        bool _available;

        uint256 _lameRate;
        uint256 _knightRate;
        uint256 _dukeRate;

        uint256 _price;
    }

    mapping(uint256 => Pack) _packs;
    uint256 _packsCount;

    uint256 _typeCount;

    uint256 nonce;

    constructor(address ft, address nft){
        _ft = FungibleToken(ft);
        _nft = NonFungibleToken(nft);
        _typeCount = 4;
    }


    //TYPES

    function addType() public onlyOwner returns(uint256) {
        _typeCount++;
        return _typeCount;
    }

    function removeType() public onlyOwner returns(uint256) {
        if(_typeCount > 4) _typeCount--;
        return _typeCount;
    }


    //PACKS

    function addPack(uint256 _lameRate, uint256 _knightRate, uint256 _dukeRate, uint256 _price) public onlyOwner{
        //check if correct
        _packsCount++;
        _packs[_packsCount] = Pack(_packsCount, false, _lameRate, _knightRate, _dukeRate, _price);
    }

    function setPackAvailability(uint256 packId, bool available) public onlyOwner {
        _packs[packId]._available = available;
    }

    function getPack(uint packId) public view returns(bool, uint256, uint256, uint256, uint256) {
        return (_packs[packId]._available, 
            _packs[packId]._lameRate,
            _packs[packId]._knightRate,
            _packs[packId]._dukeRate,
            _packs[packId]._price);
    }


    //DISCOVER NFT

    function pseudoRNG() internal virtual returns(uint256) {
        nonce++;
        return uint256(keccak256(abi.encodePacked(nonce, msg.sender, blockhash(block.number - 1))));
    }


    function discoverRank(uint packId, uint rng) internal virtual returns (uint256){
        if(rng%1000 >= _packs[packId]._lameRate) return 0;
        if(rng%1000 >= _packs[packId]._lameRate + _packs[packId]._knightRate) return 1;
        if(rng%1000 >= _packs[packId]._lameRate + _packs[packId]._knightRate + _packs[packId]._dukeRate) return 2;
        else return 3;
    }

    function discoverType(uint nb_types, uint rng) internal virtual returns (uint256){
        return rng % nb_types;
    }

    function discoverReward(uint rank, uint rng) internal virtual returns (uint256){
        return rank * 10 + rng % ((rank + 1) * 10);
    }


    function discoverNFT(uint256 packId) public returns(uint256){
        require(_packs[packId]._available, "GetNFT: Chosen pack unavailable");
        require(_ft.transferFrom(_msgSender(), address(this), _packs[packId]._price), "GetNFT: Transfer payment Failed");

        uint256 p_rnd = pseudoRNG();

        uint256 rank = discoverRank(packId, p_rnd); 
        uint256 _type = discoverType(4, p_rnd); //4 is the number of types
        uint reward = discoverReward(rank, p_rnd);

        return _nft.mint(_msgSender(), rank, _type, reward);
    }
}