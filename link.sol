// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "./Ilink.sol";

/**
 * @title ERC-Link: Link Common Token With ERC-721 Standard
 * @dev See https://eips.ethereum.org/EIPS/eip-Link
 * @dev This standard derives significantly from EIP-4786, removing opinionated logic for nested token structures, which will be seperated into a seperate EIP which inherits the Link standard
 * @dev LinkMap subgraph allows for basic front-end link viewability for any deployed ERC-Link compliant token structure
 */

abstract contract link is ERC165, Ilink {

    // TokenA -> TokenB -> LinkId -> Exists?(bool)
    mapping(address => mapping(uint256 => mapping(address => mapping(uint256 => bool)))) _link;

    modifier notZeroAddress(address _token) {
        require(
            _token != address(0),
            "token address should not be zero address"
        );
        _;
    }

    modifier tokenExists(address _token) {
        require(
            // change token checking logic for erc20 & erc1155 
            _isERC721AndExists(_token),
            "token not ERC721 token or does not exist"
        );
    }

    constructor() {}

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC165, ERC165)
        returns (bool)
    {
        return
            interfaceId == type(Ilink).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function link(
        NFT memory sourceToken,
        NFT memory targetToken,
        uint256 linkId,
        bytes memory data
    ) external tokenExists(sourceToken) tokenExists(targetToken) notZeroAddress(sourceToken.tokenAddress) notZeroAddress(targetToken.tokenAddress) {

        require(
            !linkExists(sourceToken, targetToken, linkId), 
            "Link already created at this id"
        );

        _beforeLink(sourceToken, targetToken, tokenId, data);

        _addLink(sourceToken, targetToken, linkId);

        emit Linked(msg.sender, sourceToken, targetToken, linkId, data);

        _afterLink(sourceToken, targetToken, tokenId, data);
    }
    
    function unlink(
        NFT memory sourceToken,
        NFT memory targetToken,
        uint256 linkId,
        bytes memory data
    ) external tokenExists(sourceToken) tokenExists(targetToken) notZeroAddress(sourceToken.tokenAddress) notZeroAddress(targetToken.tokenAddress) {

        // _beforeUnlink(sourceToken, targetToken, linkId, data);

        require(
            linkExists(sourceToken, targetToken, linkId), 
            "Link does not exist at this id"
        );

        _beforeUnlink(from, sourceToken, targetToken, tokenId, data);

        _removeLink(sourceToken, targetToken, linkId);

        emit Unlinked(msg.sender, sourceToken, targetToken, linkId, data);

        _afterUnlink(from, sourceToken, targetToken, tokenId, data);
    }

    function linkExists(NFT sourceToken, NFT targetToken, uint256 linkId) public view returns (bool) {
        return _link[sourceToken.tokenAddress][sourceToken.tokenId][targetToken.tokenAddress][targetToken.tokenId][linkId];
    }

    function _isERC721AndExists(NFT memory token)
        internal
        view
        returns (bool)
    {
        // Although can use try catch here, it's better to check is erc721 token in dapp.
        return
            IERC165(token.tokenAddress).supportsInterface(
                type(IERC721).interfaceId
            )
                ? IERC721(token.tokenAddress).ownerOf(token.tokenId) !=
                    address(0)
                : false;
    }

    /**
    * @dev check if specific link is bidirectional between two tokens
    */
    function isBidirectional(NFT tokenA, NFT tokenB, uint256 linkId) public view returns (bool) {
        return _link[sourceToken.tokenAddress][sourceToken.tokenId][targetToken.tokenAddress][targetToken.tokenId][linkId] && _link[targetToken.tokenAddress][targetToken.tokenId][sourceToken.tokenAddress][sourceToken.tokenId][linkId];
    }

    function _addLink(
        NFT memory sourceToken,
        NFT memory targetToken,
        uint256 linkId
    ) private {
        _link[sourceToken.tokenAddress][sourceToken.tokenId][targetToken.tokenAddress][targetToken.tokenId][linkId] = true;
    }

    function _removeLink(
        NFT memory sourceToken,
        NFT memory targetToken,
        uint256 linkId
    ) private {
        _link[sourceToken.tokenAddress][sourceToken.tokenId][targetToken.tokenAddress][targetToken.tokenId][linkId] = false;
    }

    function _beforeLink(
        NFT memory sourceToken,
        NFT memory targetToken,
        uint256 linkId,
        bytes data
    ) internal virtual {}

    function _afterLink(
        NFT memory sourceToken,
        NFT memory targetToken,
        uint256 linkId,
        bytes data 
    ) internal virtual {}

    function _beforeUnlink(
        address from,
        NFT memory sourceToken,
        NFT memory targetToken,
        uint256 linkId,
        bytes data
    ) internal virtual {}

    function _afterUnlink(
        address from,
        NFT memory sourceToken,
        NFT memory targetToken,
        uint256 linkId,
        bytes data 
    ) internal virtual {}

}