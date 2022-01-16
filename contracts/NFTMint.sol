//SPDX-Lisence-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract NFTMint is ERC721URIStorage{

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address contractAddress; //address of the marketplace where NFTs interact 

    constructor (address marketPlaceAddress)ERC721("ICONVers Tokens","ICONM"){
        contractAddress =marketPlaceAddress;
    }

/**
* MintNewToken function will create new tokens 
 */
    function MintNewToken(string memory tokenURI) public returns(uint){
        _tokenIds.increment();
        uint256 newItemId=_tokenIds.current();

        _mint(msg.sender,newItemId);  //smg.sender is the creator of new item

        // now we set the tokenURL with newItemId. (TokenURI is the actual item URI which creator wants to tokenize)
        _setTokenURI(newItemId,tokenURI);

        // give marketplace freedom to transact this token between users with in other contracts
        setApprovalForAll(contractAddress,true);
        return newItemId;
    }

}