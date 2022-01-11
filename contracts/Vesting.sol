pragma solidity ^0.8.2;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./hardhat/console.sol";

contract Vesting is Ownable {
    
    using SafeERC20 for IERC20;
    IERC20 public token;
    uint256 public startDate;

    uint256 public WEEK = 1 weeks;
    uint256 constant public MAX_SUPPLY = 10 * 10**9 * 10**18;

    uint256 public TEAM_ALLOCATION = (MAX_SUPPLY * 17) / 100; // 17%
    uint256 public TEAM_CLIFF = WEEK * 4 * 12; //1 years
    uint256 public TEAM_VESTING_DURATION = WEEK * 4 * 12 * 3; //3 years
    uint256 public TEAM_REMAINING = TEAM_ALLOCATION;
    uint256 public TEAM_WEEK_ALLOCATION = (TEAM_ALLOCATION * WEEK) / TEAM_VESTING_DURATION;
    uint256 public TEAM_LAST_UNLOCK;

    uint256 public PUBLIC_ALLOCATION = (MAX_SUPPLY * 50) / 100; // 50%
    uint256 public TGE_PUBLIC = PUBLIC_ALLOCATION;

    uint256 public COMMUNITY_ALLOCATION = (MAX_SUPPLY * 15) / 100; // 15%
    uint256 public TGE_COMMUNITY = (COMMUNITY_ALLOCATION * 10) / 100;
    uint256 public COMMUNITY_VESTING = COMMUNITY_ALLOCATION - TGE_COMMUNITY;
    uint256 public COMMUNITY_VESTING_DURATION = WEEK * 4 * 12 * 3; //3 years
    uint256 public COMMUNITY_REMAINING = COMMUNITY_VESTING;
    uint256 public COMMUNITY_WEEK_ALLOCATION = (COMMUNITY_VESTING * WEEK) / COMMUNITY_VESTING_DURATION;

    uint256 public COMMUNITY_LAST_UNLOCK;

    uint256 public FOUNDATION_RESERVE_ALLOCATION = (MAX_SUPPLY * 10) / 100; // 10%
    uint256 public FOUNDATION_RESERVE_CLIFF = WEEK * 4 * 12; //1 years
    uint256 public FOUNDATION_RESERVE_VESTING_DURATION = WEEK * 4 * 12 * 3; //3 years
    uint256 public FOUNDATION_RESERVE_REMAINING = FOUNDATION_RESERVE_ALLOCATION;
    uint256 public FOUNDATION_WEEK_ALLOCATION = (FOUNDATION_RESERVE_ALLOCATION * WEEK) / FOUNDATION_RESERVE_VESTING_DURATION;
    uint256 public FOUNDATION_RESERVE_LAST_UNLOCK;

    uint256 public LIQUIDITY_ALLOCATION = (MAX_SUPPLY * 5) / 100; // 5%
    uint256 public TGE_LIQUIDITY = LIQUIDITY_ALLOCATION;
    
    uint256 public ADVISOR_ALLOCATION = (MAX_SUPPLY * 3) / 100; // 3%
    uint256 public ADVISOR_CLIFF = WEEK * 4 * 6; //6 months
    uint256 public ADVISOR_VESTING_DURATION = WEEK * 4 * 12 * 2; //2 years
    uint256 public ADVISOR_REMAINING = ADVISOR_ALLOCATION;
    uint256 public ADVISOR_WEEK_ALLOCATION = (ADVISOR_ALLOCATION * WEEK) / ADVISOR_VESTING_DURATION;
    uint256 public ADVISOR_LAST_UNLOCK;

    constructor() {
        startDate = block.timestamp;
        TEAM_LAST_UNLOCK = startDate + TEAM_CLIFF;
        COMMUNITY_LAST_UNLOCK = startDate;
        FOUNDATION_RESERVE_LAST_UNLOCK = startDate + FOUNDATION_RESERVE_CLIFF;
        ADVISOR_LAST_UNLOCK = startDate + ADVISOR_CLIFF;
    }

    function initToken(address _token) public onlyOwner {
        require(address(_token) != address(0), "revert init");
        token = IERC20(_token);
    }

    function tgePublic() public onlyOwner {
        require(TGE_PUBLIC > 0, "TGE Public minted");
        token.safeTransfer(_msgSender(), TGE_PUBLIC);
        TGE_PUBLIC = 0;
    }

    function tgeCommunity() public onlyOwner {
        require(TGE_COMMUNITY > 0, "TGE Community minted");
        token.safeTransfer(_msgSender(), TGE_COMMUNITY);
        TGE_COMMUNITY = 0;
    }

    function tgeLiquitdity() public onlyOwner {
        require(TGE_LIQUIDITY > 0, "TGE Liquitdity minted");
        token.safeTransfer(_msgSender(), TGE_LIQUIDITY);
        TGE_LIQUIDITY = 0;
    }

    function teamVesting() public onlyOwner{
        require(startDate + TEAM_CLIFF <= block.timestamp, "cliff time");
        require(TEAM_REMAINING > 0, "VESTING END");
        
        uint256 vestingTime = (block.timestamp - TEAM_LAST_UNLOCK) / WEEK;
        uint256 mintAmount = vestingTime * TEAM_WEEK_ALLOCATION;

        if(TEAM_REMAINING >= mintAmount){
            TEAM_REMAINING = TEAM_REMAINING - mintAmount;
        } else {
            mintAmount = TEAM_REMAINING;
            TEAM_REMAINING = 0;
        }

        TEAM_LAST_UNLOCK += vestingTime * WEEK;
        token.safeTransfer(_msgSender(), mintAmount);
    }

    function communityVesting() public onlyOwner{
        require(COMMUNITY_REMAINING > 0, "VESTING END");
        
        uint256 vestingTime = (block.timestamp - COMMUNITY_LAST_UNLOCK) / WEEK;
        uint256 mintAmount = vestingTime * COMMUNITY_WEEK_ALLOCATION;

        if(COMMUNITY_REMAINING >= mintAmount){
            COMMUNITY_REMAINING = COMMUNITY_REMAINING - mintAmount;
        } else {
            mintAmount = COMMUNITY_REMAINING;
            COMMUNITY_REMAINING = 0;
        }

        COMMUNITY_LAST_UNLOCK += vestingTime * WEEK;
        token.safeTransfer(_msgSender(), mintAmount);
    }

    function foundationVesting() public onlyOwner{
        require(startDate + FOUNDATION_RESERVE_CLIFF <= block.timestamp, "cliff time");
        require(FOUNDATION_RESERVE_REMAINING > 0, "VESTING END");
        
        uint256 vestingTime = (block.timestamp - FOUNDATION_RESERVE_LAST_UNLOCK) / WEEK;
        uint256 mintAmount = vestingTime * FOUNDATION_WEEK_ALLOCATION;    
        
        if(FOUNDATION_RESERVE_REMAINING >= mintAmount){
            FOUNDATION_RESERVE_REMAINING = FOUNDATION_RESERVE_REMAINING - mintAmount;
        } else {
            mintAmount = FOUNDATION_RESERVE_REMAINING;
            FOUNDATION_RESERVE_REMAINING = 0;
        }

        FOUNDATION_RESERVE_LAST_UNLOCK += vestingTime * WEEK;
        token.safeTransfer(_msgSender(), mintAmount);
    }

    function advisorVesting() public onlyOwner{
        require(startDate + ADVISOR_CLIFF <= block.timestamp, "cliff time");
        require(ADVISOR_REMAINING > 0, "VESTING END");
        
        uint256 vestingTime = (block.timestamp - ADVISOR_LAST_UNLOCK) / WEEK;
        uint256 mintAmount = vestingTime * ADVISOR_WEEK_ALLOCATION;
 
        if(ADVISOR_REMAINING >= mintAmount){
            ADVISOR_REMAINING = ADVISOR_REMAINING - mintAmount;
        } else {
            mintAmount = ADVISOR_REMAINING;
            ADVISOR_REMAINING = 0;
        }

        ADVISOR_LAST_UNLOCK += vestingTime * WEEK;
        token.safeTransfer(_msgSender(), mintAmount);
    }
}