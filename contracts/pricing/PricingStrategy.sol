pragma solidity ^0.4.6;

/**
 * Interface for defining crowdsale pricing.
 */
contract PricingStrategy {

	function isPricingStrategy() public pure returns (bool) {
		return true;
	}

	function getCurrentBatch(uint256 tokensSold, uint256 startsAt) public view returns (uint256);

	function calculatePrice(
		uint256 weiAmount, address purchaser, uint256 tokensSold, uint256 startsAt
	) public view returns (uint256 tokenAmount);
}