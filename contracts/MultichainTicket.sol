// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

// import ownable
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MultichainTicket is ERC721Enumerable, Ownable {
    string private uri;

    constructor(string memory _uri) ERC721("MultichainTicket", "MCT") {
        uri = _uri;
    }

    function mint() external {
        _mint(_msgSender(), totalSupply() + 1);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return uri;
    }

    function setBaseURI(string memory _uri) external onlyOwner {
        uri = _uri;
    }
}
