// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

/**
 * @title ERC-Link: Link Common Token With ERC-721 Standard
 * @dev See https://eips.ethereum.org/EIPS/eip-Link
 */
interface Ilink is IERC165 {

    /**
     * @dev Representation of an ERC-721 Token
     */
    struct NFT {
        address tokenAddress;
        uint256 tokenId;
    }
    /**
     * @dev Emited when sourceToken linked to targetToken.
     * @param from who link `sourceToken` to `targetToken`
     * @param sourceToken starting node, child node
     * @param targetToken ending node, parent node
     * @param data Additional data when link to the targetToken, either the numerical index of the link or other information
     */
    event Linked(
        address from,
        NFT sourceToken,
        NFT targetToken,
        uint256 tokenId,
        bytes data
    );

    /**
     * @dev Emited when sourceToken unlinked to `to`.
     */
    event Unlinked(
        address from, 
        NFT sourceToken, 
        NFT targetToken, 
        uint256 tokenId,
        bytes data
    );

    /**
     * @dev for compatibility with balanceOfERC1155, balanceOfERC20 extensions
     * if an ERC-721 token is not linked to a targetToken, then balance is 0, otherwise it is 1
     * @param targetToken linked ERC-721 token
     * @param erc721Token a ERC-721 token
     */
    function balanceOfERC721(
        NFT memory targetToken,
        NFT memory erc721Token
    ) external view returns (uint256);

    /**
     * @dev link a ERC-721 token to another ERC-721 token
     * @param sourceToken link this token to another
     * @param targetToken linked token
     * @param data can as the order of linking to NFT or other information
     */

    function link(
        NFT memory sourceToken,
        NFT memory targetToken,
        uint256 linkId
    ) external;

    function link(
        NFT memory sourceToken,
        NFT memory targetToken,
        uint256 linkId,
        bytes memory data
    ) external;

    /**
     * @dev unlink a ERC-721 token to a address
     * @param to unlink token to this address
     * @param sourceToken unlink this token from targetToken
     * @param data can as information about token changes or other information
     */

    function unlink(
        NFT memory sourceToken,
        NFT memory targetToken,
        uint256 linkId
    ) external;

    function unlink(
        NFT memory sourceToken,
        NFT memory targetToken,
        uint256 linkId,
        bytes memory data
    ) external;

    function linkExists(
        NFT memory sourceToken,
        NFT memory targetToken,
        uint256 linkId
    ) public view returns (bool);
}