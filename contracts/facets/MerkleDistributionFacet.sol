// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibDiamond} from "../libraries/LibDiamond.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IERC721} from "../interfaces/IERC721.sol";
import {MerkleProof} from "../libraries/MerkleProof.sol";

contract MerkleDistributionFacet {

    modifier onlyOwner() {
        LibDiamond storage ds = LibDiamond.diamondStorage();
        require(msg.sender == ds.owner, "You are not the owner");
        _;
    }

    event AirdropClaimed(address indexed receiver, uint256 amount);
    event TokensWithdrawn(address indexed owner, uint256 amount);
    event MerkleRootUpdated(bytes32 indexed newMerkleRoot);

    function claimAirdrop(bytes32[] calldata proof, uint256 amount) external {
        LibDiamond storage ds = LibDiamond.diamondStorage();

        require(ds.owner != address(0), "Invalid Address: Address Zero Detected");
        require(!ds.claimed[msg.sender], "Airdrop already claimed.");
        require(IERC721(ds.baycToken).balanceOf(msg.sender) >= 1, "You don't own a BAYC Token.");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));
        require(MerkleProof.verify(proof, ds.merkleRoot, leaf), "Invalid proof.");

        ds.claimed[msg.sender] = true;

        require(IERC20(ds.baycToken).transfer(msg.sender, amount), "Token transfer failed.");

        emit AirdropClaimed(msg.sender, amount);
    }

    function withdrawTokens(uint256 amount) external onlyOwner {
        LibDiamond storage ds = LibDiamond.diamondStorage();
        require(IERC20(ds.baycToken).transfer(ds.owner, amount), "Token transfer failed.");
        emit TokensWithdrawn(ds.owner, amount);
    }

    function updateMerkleRoot(bytes32 _newMerkleRoot) external onlyOwner {
        LibDiamond storage ds = LibDiamond.diamondStorage();
        ds.merkleRoot = _newMerkleRoot;
        emit MerkleRootUpdated(_newMerkleRoot);
    }

    function checkQualification(bytes32[] calldata proof, uint256 amount) external view returns (bool) {
        LibDiamond storage ds = LibDiamond.diamondStorage();
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));
        return MerkleProof.verify(proof, ds.merkleRoot, leaf);
    }
}
