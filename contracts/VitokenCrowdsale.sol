pragma solidity ^0.4.11;

import './ownership/Ownable.sol';
import './math/SafeMath.sol';
import './token/ERC20Basic.sol';

contract VitokenCrowdsale is Ownable {

	using SafeMath for uint256;

	/* the UNIX timestamp start date of the crowdsale */
	uint256 public startsAt;

	/* the UNIX timestamp end date of the crowdsale */
	uint256 public endsAt;

	/* the number of tokens already sold through this contract*/
	uint256 public tokensSold = 0;

	/* How many wei of funding we have raised */
	uint256 public weiRaised = 0;

	uint256 public centsPerEther = 34200;
	uint256 public latestPurchaseCentsValue;


	address public wallet = 0xd7e321B8E8CC014ABe2bbB2857BEC4BEC03973EE;

	ERC20Basic tokenContract;

	/**
	* event for token purchase logging
	* @param purchaser who paid for the tokens
	* @param beneficiary who got the tokens
	* @param value weis paid for purchase
	* @param amount amount of tokens purchased
	*/
	event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

	event EventcentsPerEtherChanged(uint256 _oldcentsPerEther, uint256 _centsPerEther);


	function VitokenCrowdsale(uint256 _startsAt, uint256 _endsAt, address _tokenContract, address _wallet) {
		require(_startsAt >= 0);
		require(_endsAt >= _startsAt);
		require(_tokenContract != 0x0);
		require(_wallet != 0x0);

		startsAt = _startsAt;
		endsAt = _endsAt;
		tokenContract = ERC20Basic(_tokenContract);
		wallet = _wallet;
	}

	function setCentsPerEther(uint256 _centsPerEther) onlyOwner {
		require(_centsPerEther > 0);
		uint256 oldCentsPerEther = centsPerEther;
		centsPerEther = _centsPerEther;
		EventcentsPerEtherChanged(oldCentsPerEther, centsPerEther);
	}

	// fallback function can be used to buy tokens
	function () payable {
		buyTokens(msg.sender);
	}

	// low level token purchase function
	function buyTokens(address beneficiary) payable {
		require(beneficiary != 0x0);
		require(validPurchase());

		uint256 weiAmount = msg.value;
		uint256 centsValue = weiAmount.mul(centsPerEther).div(1E18);
		latestPurchaseCentsValue = centsValue;
		// calculate token amount to be created

		uint256 tokens = centsValue.mul(getBonusCoefficient()).div(100);

		// update state
		weiRaised = weiRaised.add(weiAmount);

		tokenContract.transfer(beneficiary, tokens);
		forwardFunds();
	}


	function validPurchase() internal constant returns (bool) {
		bool withinPeriod = ( now >= startsAt && now <= endsAt );

		bool nonZeroPurchase = msg.value != 0;
		return withinPeriod && nonZeroPurchase;
	}

	function getBonusCoefficient() constant returns (uint256) {
		return 160 - 10 * getWeek();
	}

	function getWeek() constant returns (uint256) {
		uint256 onSaleDuration = now - startsAt;

		return (onSaleDuration - onSaleDuration % 1 weeks) / 1 weeks;
	}

	function setStartsAt(uint256 _startsAt) {
		startsAt = _startsAt;
	}

	function forwardFunds() internal {
		wallet.transfer(msg.value);
	}

	function withdrawTokens(address where) onlyOwner {
		tokenContract.transfer(where, tokenContract.balanceOf(this));
	}

}