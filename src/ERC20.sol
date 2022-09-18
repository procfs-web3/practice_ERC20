// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "src/EIP712.sol";

contract ERC20 is EIP712 {
    mapping (address => uint256) private balances;
    mapping (address => mapping(address=>uint256)) private allowances;
    mapping (address => uint256) private _nonces;
    uint256 private _totalSupply;

    address private _owner;
    string private _name;
    string private _symbol;
    uint private _decimals;
    bool private _paused;

    event Transfer(address from, address to, uint256 value);
    event Approval(address owner, address spender, uint256 value);

    constructor(string memory __name, string memory __symbol) EIP712(__name, __symbol) {
        _owner = msg.sender;
        _decimals = 18;
        _mint(msg.sender, 100 ether);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint) {
        return _decimals;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return balances[owner];
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }

    function nonces(address owner) public view returns (uint256) {
        return _nonces[owner];
    }

    function _mint(address to, uint256 value) public {
        require(to != address(0));
        balances[to] += value;
        _totalSupply += value;
    }

    function _burn(address to, uint256 value) public {
        require(to != address(0));
        require(balances[to] >= value);
        unchecked {
            balances[to] -= value;
            _totalSupply -= value;
        }
    }

    function pause() public {
        require(msg.sender == _owner);
        _paused = true;
    }

    function permit(address owner, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        bytes32 structHash = keccak256(abi.encode(
            keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"), 
            owner, 
            spender, 
            amount, 
            _nonces[owner], 
            deadline
            ));
        bytes32 dataHash = _toTypedDataHash(structHash);
        address _owner = ecrecover(dataHash, v, r, s);
        require(_owner == owner, "INVALID_SIGNER");
        require(block.timestamp <= deadline);
        allowances[owner][spender] = amount;
        _nonces[owner] += 1;
    }

    function transfer(address to, uint256 value) public {
        require(!_paused);
        require(to != address(0));
        require(balances[msg.sender] >= value);
        unchecked {
            balances[msg.sender] -= value;
            balances[to] += value;
        }
        emit Transfer(msg.sender, to, value);
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        require(!_paused);
        allowances[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public {
        require(!_paused);
        require(balances[from] >= value);
        require(allowances[from][msg.sender] >= value);
        unchecked {
            balances[from] -= value;
            balances[to] += value;
            allowances[from][msg.sender] -= value;
        }
    }   
}