interface IBridge {
    function multiPassCheck(
        address ownerToVerify,
        uint16 chainId
    ) external returns (bool);
}
