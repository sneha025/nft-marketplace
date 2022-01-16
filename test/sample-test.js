const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFTMarket", function () {
  it("Should create market place for selling creating nfts", async function () {
    const Market = await ethers.getContractFactory("NFTMarket");
    const market = await Market.deploy();
    await market.deployed();

    const marketPlaceAddress =market.address 
    const NFT=await ethers.getContractFactory("NFTMint");
    const NftContract = await NFT.deploy(marketPlaceAddress);
    await NftContract.deployed();

   const nftContractAddress =NftContract.address 
   
   // listing price
   let listingPrice = await market.getListingPrice();
   listingPrice =listingPrice.toString();

   const auctionPrice =ethers.utils.parseUnits('1','ether');

   //creating tokens
   await NftContract.MintNewToken("https://www.mytokenlocation.com");
     await NftContract.MintNewToken("https://www.mytokenlocation2.com");

    await market.createMarketItem(nftContractAddress,1,auctionPrice,{value:listingPrice});

 await market.createMarketItem(nftContractAddress, 2, auctionPrice, {
   value: listingPrice,
 });

 const [_,buyerAddress] = await ethers.getSigners();

 await market.connect(buyerAddress).createMarketSell(nftContractAddress,1,{value:auctionPrice});

 let items = await market.fetchMarketItem();



items= await Promise.all(items.map(async i =>{
  const tokenUri = await NftContract.tokenURI(i.tokenId);
  let item={
    price:i.price.toString(),
    tokenId:i.tokenId.toString(),
    seller:i.seller,
    owner:i.owner,
    tokenUri
  }
return item
}));
 console.log("items: ", items);
  });
});
