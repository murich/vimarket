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

contract Destructible is Ownable {

  function Destructible() payable { } 

  /**
   * @dev Transfers the current balance to the owner and terminates the contract. 
   */
  function destroy() onlyOwner {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) onlyOwner {
    selfdestruct(_recipient);
  }
}

contract WizePresale is Ownable, Destructible {

	using SafeMath for uint256;

	uint256 public tokensSold = 0;
	uint256 public weiRaised = 0;

	uint256 public startsAt;
	address public wallet;
	ERC20Basic tokenContract;
	PricingStrategy pricingStrategy;

	event TokenPurchase(address indexed purchaser, uint256 weiAmount, uint256 tokensAmount);


	function WizePresale(
		uint256 _startsAt,
		address _wallet,
		address _tokenContract,
		address _pricingStrategy
	) {
		require(_startsAt > 0);
		require(_wallet != 0x0);
		require(_tokenContract != 0x0);
		require(_pricingStrategy != 0x0);

		startsAt = _startsAt;
		wallet = _wallet;
		tokenContract = ERC20Basic(_tokenContract);
		pricingStrategy = PricingStrategy(_pricingStrategy);
	}

	// fallback function can be used to buy tokens
	function () payable {
		buyTokens(msg.sender);
	}

	// low level token purchase function
	function buyTokens(address purchaser) payable {
		require(purchaser != 0x0);
		require(msg.value != 0);
		require(pricingStrategy.getCurrentBatch(tokensSold, startsAt) > 0);

		uint256 weiAmount = msg.value;
		uint256 tokensAmount = pricingStrategy.calculatePrice(weiAmount, purchaser, tokensSold, startsAt);

		// update state
		weiRaised = weiRaised.add(weiAmount);
		tokensSold = tokensSold.add(tokensAmount);

		tokenContract.transfer(purchaser, tokensAmount);
		TokenPurchase(purchaser, weiAmount, tokensAmount);

		forwardFunds();
	}

	function forwardFunds() internal {
		wallet.transfer(msg.value);
	}

	function withdrawTokens(address tokenAddress) external onlyOwner {
		ERC20Basic someToken = ERC20Basic(tokenAddress);
		someToken.transfer(owner, someToken.balanceOf(this));
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

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

