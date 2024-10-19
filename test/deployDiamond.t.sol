// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../contracts/Diamond.sol";

import "./helpers/DiamondUtils.sol";

contract DiamondDeployer is DiamondUtils, IDiamondCut {
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    ERC721Facet erc721Facet;

    address owner = address(0x1);
    address user1 = address(0x2);
    string tokenURI1 = "uri";
    string tokenURI2 = "uri2";

    function testDeployDiamond() public {
        //deploy facets
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(address(this), address(dCutFacet));
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        erc721Facet = new ERC721Facet();

        //upgrade diamond with facets

    function testERC721FacetNameAndSymbol() public {
            // Call the name and symbol from the ERC721Facet
            string memory name = ERC721Facet(address(diamond)).name();
            string memory symbol = ERC721Facet(address(diamond)).symbol();

            // Assert the values (assuming name and symbol are set in the Diamond's storage)
            assertEq(name, "My ERC721 Token", "Incorrect token name");
            assertEq(symbol, "M721", "Incorrect token symbol");
        }

        function testMintAndBalanceOf() public {
            // Mint a new token to user1
            vm.prank(owner); // Set msg.sender to the contract owner
            ERC721Facet(address(diamond)).mint(user1, tokenURI1);

            // Check the balance of user1
            uint256 balance = ERC721Facet(address(diamond)).balanceOf(user1);
            assertEq(balance, 1, "Incorrect token balance");

            // Check the owner of the token
            address tokenOwner = ERC721Facet(address(diamond)).ownerOf(1);
            assertEq(tokenOwner, user1, "Incorrect owner of token ID 1");
        }

        function testTokenURI() public {
            // Mint a new token to user1
            vm.prank(owner);
            ERC721Facet(address(diamond)).mint(user1, tokenURI1);

            // Check the tokenURI of the token
            string memory fetchedTokenURI = ERC721Facet(address(diamond)).tokenURI(1);
            assertEq(fetchedTokenURI, tokenURI1, "Incorrect token URI");
        }

        function testMintToZeroAddressReverts() public {
            // Expect revert on minting to address(0)
            vm.expectRevert("Mint to the zero address");
            vm.prank(owner);
            ERC721Facet(address(diamond)).mint(address(0), tokenURI1);
        }

        function testOwnerOfNonexistentTokenReverts() public {
            // Expect revert on querying a non-existent token
            vm.expectRevert("ERC721: invalid token ID");
            ERC721Facet(address(diamond)).ownerOf(999);
        }

        function testBalanceOfZeroAddressReverts() public {
            // Expect revert when checking balance of address(0)
            vm.expectRevert("ERC721: address zero is not a valid owner");
            ERC721Facet(address(diamond)).balanceOf(address(0));
        }

        //build cut struct
        FacetCut[] memory cut = new FacetCut[](2);

        cut[0] = (
            FacetCut({
                facetAddress: address(dLoupe),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

        //upgrade diamond
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

        //call a function
        DiamondLoupeFacet(address(diamond)).facetAddresses();
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}
}
