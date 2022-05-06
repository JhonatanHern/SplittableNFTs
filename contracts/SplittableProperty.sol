//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SplittableProperty is ERC721 {
    uint256 private idCounter;
    mapping(uint256 => string) public propertyMetadata;
    mapping(uint256 => uint256[]) public children; // index from a parent nft to a child nft
    mapping(uint256 => uint256[]) public combiners; // from the index of an nft resulting from a combination to the NFTs used in that combination

    constructor(string memory metadata) ERC721("Property","PRP"){
        _mint(msg.sender, idCounter);
        propertyMetadata[0] = metadata;
        idCounter++;

    }
    // create an nft based on several loose ones without any connection needed
    function combine(uint256[] calldata tokensToCombine, string calldata metadata) public {
        require(tokensToCombine.length > 1, "SplittableProperty: More than 1 NFTs to combine must be provided");
        delete combiners[idCounter];
        for(uint256 i = tokensToCombine.length; i > 0; i--){
            require(_isApprovedOrOwner(msg.sender, tokensToCombine[i - 1]), "SplittableProperty: transfer caller is not owner nor approved");
            _transfer(msg.sender, address(this), tokensToCombine[i - 1]);
            combiners[idCounter].push(tokensToCombine[i - 1]);
        }
        _mint(msg.sender, idCounter);
        propertyMetadata[idCounter] = metadata;
        idCounter++;
        
    }
    // recover the pieces from a NFT made with the `combine` function
    function decombine(uint256 combinedNFTId) public {
        require(_isApprovedOrOwner(msg.sender, combinedNFTId), "SplittableProperty: transfer caller is not owner nor approved");
        require(combiners[combinedNFTId].length > 0, "SplittableProperty: the token must have been created with a 'combine' operation");
        for(uint256 i = combiners[combinedNFTId].length; i > 0; i--){
            _transfer(address(this), msg.sender, combiners[combinedNFTId][i - 1]);
        }
        _transfer(msg.sender, address(this), combinedNFTId);
    }
    // restore an NFT that has been split into pieces from it's pieces
    function rebuild(uint256 fatherTokenId) public {
        require(children[fatherTokenId].length > 0, "SplittableProperty: the token must have been separated with a 'separate' operation");
        for(uint256 i = children[fatherTokenId].length; i > 0; i--){
            require(_isApprovedOrOwner(msg.sender, children[fatherTokenId][i - 1]), "SplittableProperty: transfer caller is not owner nor approved");
            _burn(children[fatherTokenId][i - 1]);
        }
        _transfer(address(this), msg.sender, fatherTokenId);
    }
    //create a new set of NFTs from an existing one
    function separate(uint256 fatherTokenId, string[] calldata metadataForNewNFTs) public {
        require(metadataForNewNFTs.length > 0, "SplittableProperty: new NFTs metadata not provided");
        require(_isApprovedOrOwner(msg.sender, fatherTokenId), "SplittableProperty: transfer caller is not owner nor approved");
        _transfer(msg.sender, address(this), fatherTokenId);
        delete children[fatherTokenId];
        for(uint256 i = metadataForNewNFTs.length; i > 0 ; i--){
            _mint(msg.sender, idCounter);
            propertyMetadata[idCounter] = metadataForNewNFTs[i - 1];
            children[fatherTokenId].push(idCounter);
            idCounter++;
        }
    }
}
