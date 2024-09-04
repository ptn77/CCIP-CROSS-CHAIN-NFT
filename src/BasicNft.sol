// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract BasicNft is ERC721 {
    error BasicNft__TokenUriNotFound();

    mapping(uint256 tokenId => string tokenUri) private s_tokenIdToUri;
    uint256 private s_tokenCounter;

    constructor() ERC721("Dogie", "DOG") {
        s_tokenCounter = 0;
    }

    function mintNft(string memory tokenUri) public {
        s_tokenIdToUri[s_tokenCounter] = tokenUri;
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (ownerOf(tokenId) == address(0)) {
            revert BasicNft__TokenUriNotFound();
        }

        //return s_tokenIdToUri[tokenId];
        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"',
                            name(),
                            '", "description": "',
                            "Phuong Nguyen's NFT",
                            '", ',
                            '"attributes": [{"trait_type": "',
                            "Special Image",
                            '", "value": 100}], "image":"',
                            s_tokenIdToUri[tokenId],
                            '"}'
                        )
                    )
                )
            )
        );
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}