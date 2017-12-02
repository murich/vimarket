/**
* Forked from Tokenmarket, inherits tokenmarket license
*/
pragma solidity ^0.4.6;

import '../math/SafeMath.sol';
import "../ownership/Ownable.sol";


contract WizePricingStrategy is Ownable {

	using SafeMath for uint256;

	uint public constant MAX_TRANCHES = 10;

	// This contains all pre-ICO addresses, and their prices (cents per token)
	mapping (address => uint) public preicoAddresses;

	/**
	* Define pricing schedule using tranches.
	*/
	struct Tranche {
	// Amount in tokens when this tranche becomes active
	uint amount;
	// How many cents per token user need to pay while this tranche is active
	uint price;
	}

	// Store tranches in a fixed array, so that it can be seen in a blockchain explorer
	// Tranche 0 is always (0, 0)
	Tranche[10] public tranches;

	// How many active tranches we have
	uint public trancheCount;

	function isPricingStrategy() public constant returns (bool) {
		return true;
	}

	/// @dev Contruction, creating a list of tranches
	/// @param _tranches uint[] tranches Pairs of (start amount, price)
	function WizePricingStrategy(uint[] _tranches) {
		// Need to have tuples, length check
		if(_tranches.length % 2 == 1 || _tranches.length >= MAX_TRANCHES*2) {
			revert();
		}

		trancheCount = _tranches.length / 2;

		uint highestAmount = 0;

		for(uint i=0; i<_tranches.length/2; i++) {
			tranches[i].amount = _tranches[i*2];
			tranches[i].price = _tranches[i*2+1];

			// No invalid steps
			if((highestAmount != 0) && (tranches[i].amount <= highestAmount)) {
				revert();
			}

			highestAmount = tranches[i].amount;
		}

		// Last tranche price must be zero, terminating the crowdale
		if(tranches[trancheCount-1].price != 0) {
			revert();
		}
	}

	function setPreicoAddress(address preicoAddress, uint centsPerToken) public onlyOwner
	{
		preicoAddresses[preicoAddress] = centsPerToken;
	}

	/// @dev Iterate through tranches. You reach end of tranches when price = 0
	/// @return tuple (time, price)
	function getTranche(uint n) public constant returns (uint, uint) {
		return (tranches[n].amount, tranches[n].price);
	}

	function getFirstTranche() private constant returns (Tranche) {
		return tranches[0];
	}

	function getLastTranche() private constant returns (Tranche) {
		return tranches[trancheCount-1];
	}

	function getPricingStartsAt() public constant returns (uint) {
		return getFirstTranche().amount;
	}

	function getPricingEndsAt() public constant returns (uint) {
		return getLastTranche().amount;
	}

	/// @dev Get the current tranche or bail out if we are not in the tranche periods.
	/// @param tokensSold total amount of tokens sold, for calculating the current tranche
	/// @return {[type]} [description]
	function getCurrentTranche(uint tokensSold) private constant returns (Tranche) {
		uint i;

		for(i=0; i < tranches.length; i++) {
			if(tokensSold < tranches[i].amount) {
				return tranches[i-1];
			}
		}
	}

	/// @dev Get the current price.
	/// @param tokensSold total amount of tokens sold, for calculating the current tranche
	/// @return The current price or 0 if we are outside trache ranges
	function getCurrentPrice(uint tokensSold) public constant returns (uint result) {
		return getCurrentTranche(tokensSold).price;
	}

	/// @dev Calculate the current price for buy in amount.
	function calculatePrice(uint value, uint weiRaised, uint tokensSold, address msgSender, uint decimals) public constant returns (uint) {

		uint multiplier = 10 ** decimals;

		// This investor is coming through pre-ico
		if(preicoAddresses[msgSender] > 0) {
			return value.mul(multiplier).div(preicoAddresses[msgSender]);
		}

		return value.mul(multiplier).div(getCurrentPrice(tokensSold));
	}

	function isPresalePurchase(address purchaser) public constant returns (bool) {
		return preicoAddresses[purchaser] > 0;
	}
}