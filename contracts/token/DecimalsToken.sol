pragma solidity ^0.4.11;

import './ERC20Basic.sol';

contract DecimalsToken is ERC20Basic {
	uint256 public decimals = 6;
}