// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC721/ERC721.sol)

pragma solidity 0.8.0;

import {LibDiamond} from "../libraries/LibDiamond";

contract ERC721Facet {

    function name() external view returns (string memory) {
        LibDiamond storage ds = libDiamond.DiamondStorage();
        return ds.name;
    }

    function symbol() external view returns (string memory) {
        LibDiamond storage ds = libDiamond.DiamondStorage();
        return ds.symbol;
    }

    function balanceOf(address owner) external view returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        
        LibDiamond storage ds = libDiamond.DiamondStorage();
        return ds.balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        
        LibDiamond storage ds = libDiamond.DiamondStorage();
        address owner = ds.owners[tokenId];
        
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        LibDiamond storage ds = libDiamond.DiamondStorage();
        
        require(ds.owners[tokenId] != address(0), "Token does not exist");
        
        return ds.tokenURIs[tokenId];
    }

    function mint(address to, string memory uri) external {

        require(to != address(0), "Mint to the zero address");

        LibDiamond storage ds = libDiamond.DiamondStorage();
        
        uint256 tokenId = ++_currentTokenId;
        ds.balances[to] += 1;
        ds.owners[tokenId] = to;
        ds.tokenURIs[tokenId] = uri;

        emit Minted(to, tokenId);
    }
}




