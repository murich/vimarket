pragma solidity ^0.4.11;

import './token/StandardToken.sol';
import './ownership/Ownable.sol';
import './ownership/HasNoEther.sol';
import './ownership/HasNoTokens.sol';
import './lifecycle/Destructible.sol';

contract WIZE is StandardToken, Ownable, Destructible, HasNoEther, HasNoTokens  {

	string public name = "WIZE";
	string public symbol = "WIZE";
	uint256 public decimals = 8;

	function WIZE() {
		totalSupply = 100e6 * 10**decimals;
		balances[0x14010814F3d6fBDe4970E4f7B36CdfFB23B5FA4A] = totalSupply;
	}

}
