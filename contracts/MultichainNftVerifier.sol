// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IWorldID.sol";
import "./interfaces/ILensHub.sol";
import "./interfaces/IBridge.sol";
import "./helpers/ByteHasher.sol";

contract MultichainNftVerifier is ERC721, Ownable {
    using ByteHasher for bytes;

    uint64 public constant TRANSFER_REQUEST_ID = 1;
    uint256 public constant MAX_REGISTERED = 100;

    mapping(address => bool) public registeredAddress;
    mapping(uint256 => bool) public registeredLens;
    mapping(uint256 => bool) public registeredWorldcoin;

    mapping(uint256 => string) public registeredToString;

    uint256 public totalRegistered;

    IWorldID internal immutable worldId;
    ILensHub public immutable lensHub;
    IBridge public immutable bridge;
    uint256 internal immutable externalNullifier;

    string private uri;

    constructor(
        IWorldID _worldId,
        ILensHub _lensHub,
        IBridge _bridge,
        string memory _appId,
        string memory _actionId,
        string memory _uri
    ) ERC721("PlaceHolder", "PLC") {
        _mint(msg.sender, 1);
        worldId = _worldId;
        lensHub = _lensHub;
        bridge = _bridge;
        externalNullifier = abi
            .encodePacked(abi.encodePacked(_appId).hashToField(), _actionId)
            .hashToField();
        uri = _uri;
    }

    function registerWithLens(
        uint256 _lensId,
        uint16 _chainId,
        string calldata _data
    ) external {
        require(lensHub.ownerOf(_lensId) == msg.sender, "not owner");
        require(!registeredAddress[msg.sender], "already registered");
        require(!registeredLens[_lensId], "lens handle already registered");
        require(totalRegistered < MAX_REGISTERED, "max registered");
        require(bridge.multiPassCheck(msg.sender, _chainId));
        registeredAddress[msg.sender] = true;
        registeredLens[_lensId] = true;
        totalRegistered++;
        registeredToString[totalRegistered] = _data;
    }

    function registerWithWorldcoin(
        address signal,
        uint256 root,
        uint256 nullifierHash,
        uint256[8] calldata proof,
        uint16 _chainId,
        string calldata _data
    ) external {
        require(!registeredAddress[msg.sender], "already registered");
        require(
            !registeredWorldcoin[nullifierHash],
            "worldid already registered"
        );
        require(totalRegistered < MAX_REGISTERED, "max registered");
        require(bridge.multiPassCheck(msg.sender, _chainId));
        worldId.verifyProof(
            root,
            1,
            abi.encodePacked(signal).hashToField(),
            nullifierHash,
            externalNullifier,
            proof
        );

        registeredAddress[msg.sender] = true;
        registeredWorldcoin[nullifierHash] = true;
        totalRegistered++;
        registeredToString[totalRegistered] = _data;
    }

    function registerWithoutId(
        uint16 _chainId,
        string calldata _data
    ) external {
        require(!registeredAddress[msg.sender], "already registered");
        require(bridge.multiPassCheck(msg.sender, _chainId));
        registeredAddress[msg.sender] = true;
        totalRegistered++;
        registeredToString[totalRegistered] = _data;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return uri;
    }

    function setBaseURI(string memory _uri) external onlyOwner {
        uri = _uri;
    }
}
