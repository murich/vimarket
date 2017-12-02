pragma solidity ^0.4.11;

import './ownership/Ownable.sol';
import './token/ERC20Basic.sol';
import './lifecycle/Destructible.sol';
import './math/SafeMath.sol';
import './pricing/PricingStrategy.sol';

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
