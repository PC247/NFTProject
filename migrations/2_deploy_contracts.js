var NonFungibleToken = artifacts.require("NonFungibleToken");
var FungibleToken = artifacts.require("FungibleToken");

var GetNFT = artifacts.require("GetNFT");
var NFTGame = artifacts.require("NFTGame");

var ft_symbol = "BNT";
var ft_name = "BananeToken";

var nft_symbol = "HNG";
var nft_name = "Hungan";
var nft_tokenUri = "";

module.exports = deployer => {
  deployer.then(async () => {
    await deployer.deploy(FungibleToken, ft_name, ft_symbol);
    const FungibleTokenInstance = await FungibleToken.deployed();
    
    await deployer.deploy(NonFungibleToken, nft_name, nft_symbol, nft_tokenUri);
    const NonFungibleTokenInstance = await NonFungibleToken.deployed();

    await deployer.deploy(GetNFT, FungibleToken.address, NonFungibleToken.address, 1);
    await NonFungibleTokenInstance.grantMinterRole(GetNFT.address);

    await deployer.deploy(NFTGame, FungibleToken.address, NonFungibleToken.address);
    await NonFungibleTokenInstance.grantMinterRole(NFTGame.address);
    await FungibleTokenInstance.grantMinterRole(NFTGame.address);
  });
};