pragma solidity ^0.4.13;

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract PricingStrategy {

	function isPricingStrategy() public pure returns (bool) {
		return true;
	}

	function getCurrentBatch(uint256 tokensSold, uint256 startsAt) public view returns (uint256);

	function calculatePrice(
		uint256 weiAmount, address purchaser, uint256 tokensSold, uint256 startsAt
	) public view returns (uint256 tokenAmount);
}

contract WizePricingStrategy is Ownable, PricingStrategy {

	using SafeMath for uint256;


	// This contains all pre-ICO addresses, and their prices (cents per token)
	mapping (address => uint256) public preicoAddresses;

	uint256 tokenDecimals = 8;

	uint256 batchAmount1 = 4e6 * 10**tokenDecimals;
	uint256 batchAmount2 = 2e6 * 10**tokenDecimals;
	uint256 batchAmount3 = 2e6 * 10**tokenDecimals;
	uint256 batchAmount4 = 2e6 * 10**tokenDecimals;

	uint256 batchDuration1 = 18;
	uint256 batchDuration2 = 13;
	uint256 batchDuration3 = 11;
	uint256 batchDuration4 = 14;

	mapping (uint256 => uint256) public batchPrices;

	uint256 BATCH_1 = 1;
	uint256 BATCH_2 = 2;
	uint256 BATCH_3 = 3;
	uint256 BATCH_4 = 4;

	uint256 public centsPerEther = 45000;

	event CentsPerEtherChanged(uint256 _oldcentsPerEther, uint256 _centsPerEther);


	function WizePricingStrategy() {
		batchPrices[BATCH_1] = 75;
		batchPrices[BATCH_2] = 120;
		batchPrices[BATCH_3] = 135;
		batchPrices[BATCH_4] = 142;
	}

	function setPreicoAddress(address preicoAddress, uint256 centsPerToken) public onlyOwner
	{
		preicoAddresses[preicoAddress] = centsPerToken;
	}


	function getAmountBasedCurrentBatch(uint256 tokensSold) constant returns (uint256) {
		uint256 tokensSoldLimit = batchAmount1;
		if (tokensSold < tokensSoldLimit) {
			return BATCH_1;
		}

		tokensSoldLimit = tokensSoldLimit.add(batchAmount2);
		if (tokensSold < tokensSoldLimit) {
			return BATCH_2;
		}

		tokensSoldLimit = tokensSoldLimit.add(batchAmount3);
		if (tokensSold < tokensSoldLimit) {
			return BATCH_3;
		}

		tokensSoldLimit = tokensSoldLimit.add(batchAmount4);
		if (tokensSold < tokensSoldLimit) {
			return BATCH_4;
		}

		return 0;
	}

	function getDateBasedCurrentBatch(uint256 startsAt)  constant returns (uint256) {
		uint256 batchEndsTimestamp = startsAt + batchDuration1 * 86400;
		if (now < batchEndsTimestamp) {
			return BATCH_1;
		}

		batchEndsTimestamp = batchEndsTimestamp.add(batchDuration2 * 86400);
		if (now < batchEndsTimestamp) {
			return BATCH_2;
		}

		batchEndsTimestamp = batchEndsTimestamp.add(batchDuration3 * 86400);
		if (now < batchEndsTimestamp) {
			return BATCH_3;
		}

		batchEndsTimestamp = batchEndsTimestamp.add(batchDuration4 * 86400);
		if (now < batchEndsTimestamp) {
			return BATCH_4;
		}

		return 0;
	}

	function getCurrentBatch(uint256 tokensSold, uint256 startsAt) public view returns (uint256) {
		uint256 amountBased = getAmountBasedCurrentBatch(tokensSold);
		uint256 dateBased = getDateBasedCurrentBatch(startsAt);

		if (amountBased == 0 || dateBased == 0) {
			return 0;
		}
		return (amountBased > dateBased) ? amountBased : dateBased;
	}

	/// @return The current price or 0 if we are outside trache ranges
	function getCurrentPrice(uint256 tokensSold, uint256 startsAt) public view returns (uint256 result) {
		return batchPrices[getCurrentBatch(tokensSold, startsAt)];
	}

	/// @dev Calculate the token amount for a particular pruchase.
	function calculatePrice(
		uint256 weiAmount, address purchaser, uint256 tokensSold, uint256 startsAt
	) public constant returns (uint256) {
		uint256 centsValue = weiAmount.mul(centsPerEther).div(1e18);

		// This investor is coming through pre-ico
		if(isPresalePurchase(purchaser)) {
			return centsValue.mul(10**tokenDecimals).div(preicoAddresses[purchaser]);
		}

		return centsValue.mul(10**tokenDecimals).div(getCurrentPrice(tokensSold, startsAt));
	}

	function isPresalePurchase(address purchaser) public constant returns (bool) {
		return preicoAddresses[purchaser] > 0;
	}

	function setCentsPerEther(uint256 _centsPerEther) onlyOwner {
		require(_centsPerEther > 0);
		uint256 oldCentsPerEther = centsPerEther;
		centsPerEther = _centsPerEther;
		CentsPerEtherChanged(oldCentsPerEther, centsPerEther);
	}
}

