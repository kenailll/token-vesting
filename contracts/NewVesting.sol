/**
 *Submitted for verification at BscScan.com on 2021-12-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./hardhat/console.sol";


contract ERC20Vesting is Ownable{
    // Contract libs
    using SafeERC20 for IERC20;

    // Contract events
    event Released(address indexed beneficiary, uint256 amount);

    // Vesting information struct
    struct VestingBeneficiary {
        address beneficiary;
        uint256 lockDuration;
        uint256 duration;
        uint256 amount;
        uint256 leftOverVestingAmount;
		uint256 amountPerInterval;
        uint256 upfrontAmount;
        uint256 startedAt;
        uint256 interval;
        uint256 lastReleasedAt;
    }

    IERC20 public token;
    // Vesting beneficiary list
    mapping(address => VestingBeneficiary) public beneficiaries;
    address[] public beneficiaryAddresses;
    // Token deployed date
    uint256 public tokenListingDate = block.timestamp;
    uint256 public tokenVestingCap;

    constructor(address _token, uint256 _tokenListingDate) {
        require(_token != address(0), "The token's address cannot be 0");
        token = IERC20(_token);
        if (_tokenListingDate > 0) {
            tokenListingDate = _tokenListingDate;
        }
    }

    // only added beneficiaries can release the vesting amount
    modifier onlyBeneficiaries() {
        require(beneficiaries[_msgSender()].amount > 0,"You cannot release tokens!");
        _;
    }

    /**
     * @dev Add new beneficiary to vesting contract with some conditions.
     */
    function addBeneficiary(
        address _beneficiary,
        uint256 _amount,
        uint256 _lockDuration,
        uint256 _duration,
        uint256 _upfrontAmount,
        uint256 _interval
    ) public onlyOwner {
        require(
            _beneficiary != address(0),
            "The beneficiary's address cannot be 0"
        );

        require(_amount > 0, "Shares amount has to be greater than 0");
        require(
            tokenVestingCap + _amount <= token.totalSupply(),
            "Full token vesting to other beneficiaries. Can not add new beneficiary"
        );
        require(
            beneficiaries[_beneficiary].amount == 0,
            "The beneficiary has added to the vesting pool already"
        );

        // Add new vesting beneficiary
        uint256 _leftOverVestingAmount = _amount;
		
		uint256 _amountPerInterval = 0;
		if(_duration != 0 && _interval != 0){
        	_amountPerInterval = ((_amount - _upfrontAmount) * _interval) / _duration;
		}

        uint256 vestingStartedAt = tokenListingDate + _lockDuration;

        beneficiaries[_beneficiary] = VestingBeneficiary(
            _beneficiary,
            _lockDuration,
            _duration,
            _amount,
            _leftOverVestingAmount,
            _amountPerInterval,
            _upfrontAmount,
            vestingStartedAt,
            _interval,
            0
        );

        beneficiaryAddresses.push(_beneficiary);
        tokenVestingCap = tokenVestingCap + _amount;
    }

    /**
     * @dev Get new vested amount of beneficiary base on vesting schedule of this beneficiary.
     */
    function releasableAmount(address _beneficiary) public view returns (uint256, uint256)
    {
        if (beneficiaries[_beneficiary].leftOverVestingAmount <= 0){
            return (0, beneficiaries[_beneficiary].lastReleasedAt);
        }

        if (block.timestamp - beneficiaries[_beneficiary].lastReleasedAt < beneficiaries[_beneficiary].interval){
			return (0, beneficiaries[_beneficiary].lastReleasedAt);
        }

        (uint256 _vestedAmount, uint256 _lastIntervalDate) = vestedAmount(_beneficiary);
        return (_vestedAmount, _lastIntervalDate);
    }

    /**
     * @dev Get total vested amount of beneficiary base on vesting schedule of this beneficiary.
     */
    function vestedAmount(address _beneficiary) public view returns (uint256, uint256)
    {
        require(beneficiaries[_beneficiary].amount > 0, "The beneficiary's address cannot be found");
        
        // Transfer immediately if any upfront amount
        if (beneficiaries[_beneficiary].upfrontAmount > 0 && beneficiaries[_beneficiary].lastReleasedAt == 0) {
			return (
				beneficiaries[_beneficiary].upfrontAmount,
				beneficiaries[_beneficiary].startedAt
			);
        }

        // No vesting (All amount unlock at the TGE)
        if (beneficiaries[_beneficiary].duration == 0) {
            return (
				beneficiaries[_beneficiary].amount,
				beneficiaries[_beneficiary].startedAt
			);
        }
		
        // Vesting has not started yet
        if (block.timestamp < beneficiaries[_beneficiary].startedAt) {
            return (
				beneficiaries[_beneficiary].amount - beneficiaries[_beneficiary].leftOverVestingAmount, 
				beneficiaries[_beneficiary].lastReleasedAt
			);
        }

        // Vesting is done
        if (beneficiaries[_beneficiary].leftOverVestingAmount <= 0) {
            return (
				beneficiaries[_beneficiary].amount,
				beneficiaries[_beneficiary].startedAt + beneficiaries[_beneficiary].duration
			);
        }

        // It's too soon to next release
        if (
            beneficiaries[_beneficiary].lastReleasedAt > 0 &&
            block.timestamp < beneficiaries[_beneficiary].lastReleasedAt + beneficiaries[_beneficiary].interval
        ){
            return (
				beneficiaries[_beneficiary].amount - beneficiaries[_beneficiary].leftOverVestingAmount, 
				beneficiaries[_beneficiary].lastReleasedAt
			);
        }

        // Vesting is interval counter
        uint256 totalVestedAmount = beneficiaries[_beneficiary].amount - beneficiaries[_beneficiary].leftOverVestingAmount;
        uint256 lastIntervalDate = beneficiaries[_beneficiary].lastReleasedAt > 0
		? beneficiaries[_beneficiary].lastReleasedAt
        : beneficiaries[_beneficiary].startedAt;

        uint256 multiplyIntervals = (block.timestamp - lastIntervalDate) / beneficiaries[_beneficiary].interval;

        if (multiplyIntervals > 0) {
            totalVestedAmount = beneficiaries[_beneficiary].amountPerInterval * multiplyIntervals;
			lastIntervalDate += beneficiaries[_beneficiary].interval * multiplyIntervals;
        }

        return (totalVestedAmount, lastIntervalDate);
    }

    /**
     * @dev Release vested tokens to a specified beneficiary.
     */
    function releaseTo(
        address _beneficiary,
        uint256 _amount,
        uint256 _lastIntervalDate
    ) internal returns (bool) {
        if (block.timestamp < _lastIntervalDate) {
            return false;
        }
        // Update beneficiary information
		if(beneficiaries[_beneficiary].leftOverVestingAmount >= _amount){
        	beneficiaries[_beneficiary].leftOverVestingAmount -= _amount;
		} else {
			_amount = beneficiaries[_beneficiary].leftOverVestingAmount;
			beneficiaries[_beneficiary].leftOverVestingAmount = 0;
		}

        beneficiaries[_beneficiary].lastReleasedAt = _lastIntervalDate;

        // Emit event to of new release
        emit Released(_beneficiary, _amount);
        // Transfer new released amount to vesting beneficiary
        token.safeTransfer(_beneficiary, _amount);
        return true;
    }

    /**
     * @dev Release vested tokens to current beneficiary.
     */
    function releaseMyTokens() external onlyBeneficiaries {
        // Calculate the releasable amount
        (
        uint256 _releaseAmount,
        uint256 _lastIntervalDate
        ) = releasableAmount(_msgSender());
	
        // Release new vested token to the beneficiary
        if (_releaseAmount > 0) {
            releaseTo(_msgSender(), _releaseAmount, _lastIntervalDate);
        }
    }
}