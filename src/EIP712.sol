//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract EIP712 {

    bytes32 private DOMAIN_SEPARATOR;
    
    constructor(string memory name, string memory version) {
        DOMAIN_SEPARATOR = keccak256(abi.encodePacked(msg.sender));
    }

    function _domainSeparator() public view returns (bytes32) {
        return DOMAIN_SEPARATOR;
    }
    
    function _toTypedDataHash(bytes32 structHash) public returns (bytes32) {
        bytes memory encoded = abi.encodePacked(bytes2("\x19\x01"), DOMAIN_SEPARATOR, structHash);
        return keccak256(encoded);
    }

}