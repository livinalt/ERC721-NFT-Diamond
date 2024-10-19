// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibDiamond } from "../libraries/LibDiamond.sol";

contract ERC721Facet {

    event Minted(address indexed to, uint256 indexed tokenId);

    function name() external view returns (string memory) {
        LibDiamond storage ds = LibDiamond.diamondStorage();
        return ds.name;
    }

    function symbol() external view returns (string memory) {
        LibDiamond storage ds = LibDiamond.diamondStorage();
        return ds.symbol;
    }

    function balanceOf(address owner) external view returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        
        LibDiamond storage ds = LibDiamond.diamondStorage();
        return ds.balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        LibDiamond storage ds = LibDiamond.diamondStorage();
        address owner = ds.owners[tokenId];
        
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        LibDiamond storage ds = LibDiamond.diamondStorage();
        
        require(ds.owners[tokenId] != address(0), "Token does not exist");
        
        return ds.tokenURIs[tokenId];
    }

    function mint(address to, string memory uri) external {
        require(to != address(0), "Mint to the zero address");

        LibDiamond storage ds = LibDiamond.diamondStorage();
        
        uint256 tokenId = ++ds.currentTokenId; // Fixed reference to currentTokenId
        ds.balances[to] += 1;
        ds.owners[tokenId] = to;
        ds.tokenURIs[tokenId] = uri;

        emit Minted(to, tokenId);
    }
}
