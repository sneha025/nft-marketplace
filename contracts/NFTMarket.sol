// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarket is ReentrancyGuard{

    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemSold;

    address payable owner;

    uint256 listingPrice =0.0025 ether;

    constructor(){
        owner=payable(msg.sender); // address or owner who deployed this contract
    }

    struct MarketItem{
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }
    // a mapping for itemId to marketItems
    mapping(uint256=>MarketItem) private idToMarketItem;

    // event whenever new marketItem created 
    event MarketItemCreated(
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    function getListingPrice() public view returns (uint256){
        return listingPrice;
    }

//function for creating market item and puting it for sell.
    function createMarketItem(
        address nftContract,
        uint tokenId,
        uint256 price
    ) public payable nonReentrant {
        require(price>0,"Price must be at least 1 wei");
    require(msg.value==listingPrice,"Price must be equal to listing price");

    _itemIds.increment();
    uint256 itemId=_itemIds.current(); // id for market place item which is going for sale

    idToMarketItem[itemId]=MarketItem(
        itemId,
        nftContract,
        tokenId,
        payable(msg.sender), //address of seller
        payable(address(0)),  //address of owner, currently it is no one, because seller puting new item for sell and no one owns it yet
        price,
        false
        );

        // want to transfer the ownership to this contract and this contract take ownership and transfer to other buyer/contract
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit MarketItemCreated(
        itemId,
        nftContract,
        tokenId,
        msg.sender,
        address(0),
        price,
        false
    );

    }

// function for buyer
    function createMarketSell(address nftContract,uint256 itemId) public payable nonReentrant{

        uint price=idToMarketItem[itemId].price;
        uint tokenId=idToMarketItem[itemId].tokenId;

        require(msg.value== price,"Please submit the asking price in the order to complete purchase");
        
        // transfer the value to the seller
        idToMarketItem[itemId].seller.transfer(msg.value);

        // tranfering the ownership of the asset 
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        idToMarketItem[itemId].owner=payable(msg.sender);
        idToMarketItem[itemId].sold=true;
        _itemSold.increment();
        payable(owner).transfer(listingPrice);

    }

//function fetch all items listed on market place
function fetchMarketItem() public view returns (MarketItem[] memory){
    uint itemCount =_itemIds.current();
    uint unsoldItemCount =_itemIds.current()-_itemSold.current();
    uint currentIndex =0;

    // create array of MarketItem
    MarketItem[] memory items=new MarketItem[](unsoldItemCount);

    for(uint i=0;i<itemCount;i++){
        if(idToMarketItem[i+1].owner==address(0)){
            // then add that market item into items array
            uint currentId=idToMarketItem[i+1].itemId;
            MarketItem storage currentItem = idToMarketItem[currentId];
            items[currentIndex]=currentItem;
            currentIndex+=1;
        }
    }
    return items;


}
    // function  returning array of nfts owns by the user
    function fetchMyNFTs() public view returns(MarketItem[] memory){

        uint totalItemCount =_itemIds.current();
        uint itemCount = 0 ; // for counting the items/nfts which user owns
        uint currentIndex=0;

        // first find the count current user owns
        for(uint i =0;i<totalItemCount;i++){
            if(idToMarketItem[i+1].owner==msg.sender){
                itemCount+=1;
        }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for(uint i=0;i<totalItemCount;i++){
            if(idToMarketItem[i+1].owner== msg.sender){
                uint currentId =idToMarketItem[i+1].itemId;
                MarketItem storage currentItem=idToMarketItem[currentId];
                items[currentIndex]=currentItem;
                currentIndex+=1;
        }
        }

    return items;
    }

    // function returning list of nfts created by user
    function fetchNFTsCreatedBy() public view returns(MarketItem[] memory){
        uint totalItemsCount =_itemIds.current();
        uint itemCount=0;
        uint currentIndex =0;

        for (uint i=0;i<totalItemsCount;i++){
            if(idToMarketItem[i+1].seller== msg.sender){
                itemCount+=1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for(uint i=0;i<totalItemsCount;i++){

            if(idToMarketItem[i+1].seller == msg.sender){
                uint currentId=idToMarketItem[i+1].itemId;
                MarketItem storage currentItem=idToMarketItem[currentId];
                items[currentIndex]=currentItem;
                currentIndex+=1;
            }
        }

        return items;
    }

}