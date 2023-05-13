// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./ZKPVerifier.sol";
import "./interfaces/IWorldID.sol";
import "./interfaces/ILensHub.sol";
import "./interfaces/IBridge.sol";
import "./helpers/ByteHasher.sol";

contract MultichainNftVerifier is ERC721, ZKPVerifier {
    using ByteHasher for bytes;

    uint64 public constant TRANSFER_REQUEST_ID = 1;
    uint256 public constant MAX_REGISTERED = 500;

    mapping(address => bool) public registeredAddress;
    mapping(uint256 => bool) public registeredLens;
    mapping(uint256 => bool) public registeredWorldcoin;

    mapping(uint256 => address) public idToAddress;
    mapping(address => uint256) public addressToId;

    mapping(uint256 => bytes) public registeredToData;

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
        _mint(_msgSender(), 1);
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
        bytes calldata _data
    ) external {
        require(lensHub.ownerOf(_lensId) == _msgSender(), "not owner");
        require(!registeredAddress[_msgSender()], "already registered");
        require(!registeredLens[_lensId], "already lens registered");
        require(totalRegistered < MAX_REGISTERED, "max registered");
        require(bridge.multiPassCheck(_msgSender(), _chainId));
        registeredAddress[_msgSender()] = true;
        registeredLens[_lensId] = true;
        totalRegistered++;
        registeredToData[totalRegistered] = _data;
    }

    function registerWithPolygonId(
        uint64 requestId,
        uint256[] memory inputs,
        ICircuitValidator validator,
        uint16 _chainId,
        bytes calldata _data
    ) external {
        require(!registeredAddress[_msgSender()], "already registered");
        require(totalRegistered < MAX_REGISTERED, "max registered");
        require(bridge.multiPassCheck(_msgSender(), _chainId));
        registeredAddress[_msgSender()] = true;
        _beforeProofSubmit(requestId, inputs, validator);
        _afterProofSubmit(requestId, inputs, validator);
        totalRegistered++;
        registeredToData[totalRegistered] = _data;
    }

    function registerWithWorldcoin(
        address signal,
        uint256 root,
        uint256 nullifierHash,
        uint256[8] calldata proof,
        uint16 _chainId,
        bytes calldata _data
    ) external {
        require(!registeredAddress[_msgSender()], "already registered");
        require(!registeredWorldcoin[nullifierHash], "already registered");
        require(totalRegistered < MAX_REGISTERED, "max registered");
        require(bridge.multiPassCheck(_msgSender(), _chainId));
        worldId.verifyProof(
            root,
            1,
            abi.encodePacked(signal).hashToField(),
            nullifierHash,
            externalNullifier,
            proof
        );
        registeredAddress[_msgSender()] = true;
        registeredWorldcoin[nullifierHash] = true;
        totalRegistered++;
        registeredToData[totalRegistered] = _data;
    }

    function registerWithoutId(uint16 _chainId) external {
        require(!registeredAddress[_msgSender()], "already registered");
        require(bridge.multiPassCheck(_msgSender(), _chainId));
        registeredAddress[_msgSender()] = true;
    }

    function finalizeRegister() external {}

    function _beforeProofSubmit(
        uint64 /* requestId */,
        uint256[] memory inputs,
        ICircuitValidator validator
    ) internal view override {
        // check that the challenge input of the proof is equal to the _msgSender()
        address addr = GenesisUtils.int256ToAddress(
            inputs[validator.getChallengeInputIndex()]
        );
        require(
            _msgSender() == addr,
            "address in the proof is not a sender address"
        );
    }

    function _afterProofSubmit(
        uint64 requestId,
        uint256[] memory inputs,
        ICircuitValidator validator
    ) internal override {
        require(
            requestId == TRANSFER_REQUEST_ID && addressToId[_msgSender()] == 0,
            "proof can not be submitted more than once"
        );

        uint256 id = inputs[validator.getChallengeInputIndex()];

        if (idToAddress[id] == address(0)) {
            addressToId[_msgSender()] = id;
            idToAddress[id] = _msgSender();
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return uri;
    }

    function setBaseURI(string memory _uri) external onlyOwner {
        uri = _uri;
    }
}
