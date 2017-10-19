pragma solidity ^0.4.11;

import './token/MintableToken.sol';

contract Vitoken is MintableToken {

	string public name = "Vitoken";
	string public symbol = "VIT";
	uint256 public decimals = 2;


	address constant offlineSaleAddress = 0x38216B54f4E2e6303C3EF2e02A5783B5D2B7D62d;
	uint256 constant offlineSaleAmount = 2e10;

	address constant advisorsFundAddress = 0x8ba8e02f690fFF10DA2393aFf5Ab1f58C37FA2f2;
	uint256 constant advisorsFundAmount = 12500000 * 100;

	address constant foundersEmployeesFundAddress = 0xD22383263ec1527c80e5B0Ce7541dCd35De29a09;
	uint256 constant foundersEmployeesFundAmount = 85500000 * 100;

	address constant incentivesFundAddress = 0x36414a490C64f2a0646F77FdE208C6DdF309a7e3;
	uint256 constant incentivesFundAmount = 2000000 * 100;

	address constant reserveFundAddress = 0xF0eA0cf1119AA543b442C0EDd0B60124a6B673D8;
	uint256 constant reserveFundAmount = 9.6 * 10**9 * 100;

	function Vitoken()
	{
		mint(offlineSaleAddress, offlineSaleAmount);
		mint(advisorsFundAddress, advisorsFundAmount);
		mint(foundersEmployeesFundAddress, foundersEmployeesFundAmount);
		mint(incentivesFundAddress, incentivesFundAmount);
		mint(reserveFundAddress, reserveFundAmount);

		finishMinting();
	}

}
