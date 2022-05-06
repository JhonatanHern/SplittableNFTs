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
        for(uint256 i = tokensToCombine.length - 1; i >= 0; i--){
            require(_isApprovedOrOwner(msg.sender, tokensToCombine[i]), "SplittableProperty: transfer caller is not owner nor approved");
            _transfer(msg.sender, address(this), tokensToCombine[i]);
            combiners[idCounter].push(tokensToCombine[i]);
        }
        _mint(msg.sender, idCounter);
        propertyMetadata[idCounter] = metadata;
        idCounter++;
        
    }
    // recover the pieces from a NFT made with the `combine` function
    function decombine(uint256 combinedNFTId) public {
        require(_isApprovedOrOwner(msg.sender, combinedNFTId), "SplittableProperty: transfer caller is not owner nor approved");
        for(uint256 i = combiners[combinedNFTId].length - 1; i >= 0; i--){
            _transfer(address(this), msg.sender, combiners[combinedNFTId][i]);
        }
        _transfer(msg.sender, address(this), combinedNFTId);
    }
    // restore an NFT that has been split into pieces from it's pieces
    function rebuild(uint256 fatherTokenId) public {
        for(uint256 i = children[fatherTokenId].length - 1; i >= 0; i--){
            require(_isApprovedOrOwner(msg.sender, children[fatherTokenId][i]), "SplittableProperty: transfer caller is not owner nor approved");
            _burn(children[fatherTokenId][i]);
        }
        _transfer(address(this), msg.sender, fatherTokenId);
    }
    //create a new set of NFTs from an existing one
    function separate(uint256 fatherTokenId, string[] calldata metadataForNewNFTs) public {
        require(_isApprovedOrOwner(msg.sender, fatherTokenId), "SplittableProperty: transfer caller is not owner nor approved");
        _transfer(msg.sender, address(this), fatherTokenId);
        for(uint256 i = 0; i < metadataForNewNFTs.length; i++){
            _mint(msg.sender, idCounter);
            propertyMetadata[idCounter] = metadataForNewNFTs[i];
            children[fatherTokenId].push(idCounter);
            idCounter++;
        }
    }
}
