// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import { ERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IKittyVault } from "./interfaces/IKittyVault.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { IAavePool } from "./interfaces/IAavePool.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

contract KittyVault {
    using SafeERC20 for IERC20;
    using Math for uint256;

    error KittyVault__NotPool();
    error KittyVault__NotMeowntainerPurrrrr();

    address public immutable i_token;
    address public immutable i_pool;
    AggregatorV3Interface public immutable i_priceFeed;
    AggregatorV3Interface public immutable i_euroPriceFeed;
    address public meowntainer;
    IAavePool public immutable i_aavePool;
    uint256 public totalMeowllateralInVault;

    mapping(address user => uint256 cattyNip) public userToCattyNip;
    uint256 public totalCattyNip;

    uint256 private constant EXTRA_DECIMALS = 1e10;
    uint256 private constant PRECISION = 1e18;

    modifier onlyMeowntainer {
        require(msg.sender == meowntainer, KittyVault__NotMeowntainerPurrrrr());
        _;
    }

    modifier onlyPool() {
        require(msg.sender == i_pool, KittyVault__NotPool());
        _;
    }

    constructor(address _token, address _pool, address _priceFeed, address _euroPriceFeed, address _meowntainer, address _aavePool) {
        i_token = _token;
        i_pool = _pool;
        i_priceFeed = AggregatorV3Interface(_priceFeed);
        i_euroPriceFeed = AggregatorV3Interface(_euroPriceFeed);
        meowntainer = _meowntainer;
        i_aavePool = IAavePool(_aavePool);
    }

    // I expect this function to deposit collateral
    function executeDepawsit(address _user, uint256 _ameownt) external onlyPool {
        // Here, the variable is assigned a value
        uint256 _totalMeowllateral = getTotalMeowllateral();
        // This declares a variable and type
        uint256 _cattyNipGenerated;

        if (_totalMeowllateral == 0) {
            _cattyNipGenerated = _ameownt;
        }
        else {
            _cattyNipGenerated = _ameownt.mulDiv(totalCattyNip, _totalMeowllateral);
        }

        userToCattyNip[_user] += _cattyNipGenerated;
        totalCattyNip += _cattyNipGenerated;
        totalMeowllateralInVault += _ameownt;

        // executing transfer FROM user
        IERC20(i_token).safeTransferFrom(_user, address(this), _ameownt);
    }

    // this function is expected to execute withdrawal
    function executeWhiskdrawal(address _user, uint256 _cattyNipToWithdraw) external onlyPool {
        // this line calculates the amount of collateral to be withdrawn
        // by executing the mulDiv operation
        // the calculated amount is then stored to the variable _ameownt as a a uint256 value
        uint256 _ameownt = _cattyNipToWithdraw.mulDiv(getTotalMeowllateral(), totalCattyNip);
        // this line is a mapping of userToCattyNip linked to users address
        // the amount of cattyNip specified by _cattyNipToWithdraw
        // then subtracted from the user's balance in the userToCattyNip mapping
        userToCattyNip[_user] -= _cattyNipToWithdraw;
        // this line keeps track of cattyNip
        // after cattyNip is withdrawn
        totalCattyNip -= _cattyNipToWithdraw;
        // this line displays the amount withdrawn from the totalMeowllateralInVault
        totalMeowllateralInVault -= _ameownt;

        // executing withdrawal amount to user
        IERC20(i_token).safeTransfer(_user, _ameownt);
    }


    ////////////////////////////////////////////
    ////////// AAVE SUPPLY FOR INTEREST ////////
    //////////////////////////////////////////// 
    
    // This function is expected to supply collateral to aave
    // the function call is modified by onlyMeowntainer
    function purrrCollateralToAave(uint256 _ameowntToSupply) external onlyMeowntainer {
        // Here, the totalMeowllateralInVault is subtracted from the _ameowntToSupply
        totalMeowllateralInVault -= _ameowntToSupply;
        // This line allows i_aavePool to spend
        // i_token specified _ameowntToSupply
        // by using i_aavePool address
        IERC20(i_token).approve(address(i_aavePool), _ameowntToSupply);
        // Here, the function supplies a specified amount 
        // of the i_token to the aavePool
        // onBehalfOf the aavePool
        // no referral code is applied during this supply operation.
        i_aavePool.supply( { asset: i_token, amount: _ameowntToSupply, onBehalfOf: address(this), referralCode: 0 } );
    }

    // This function is expected to withdraw from aave
    // the function can be called by the modifier onlyMeowntainer 
    function purrrCollateralFromAave(uint256 _ameowntToWhiskdraw) external onlyMeowntainer {
        // Here, the totalMeowllateralInVault is added to the amount to withdraw
        // q are you supposed to add the totalMeowllateralInVault to _ameowntToWhiskdraw?
        totalMeowllateralInVault += _ameowntToWhiskdraw;

        // Here, the withdraw function of aavePool is called
        // with the asset to be withdrawn which is the i_token
        // the amount to be withdrawn
        // and the destination of the contract's address as address(this) 
        i_aavePool.withdraw( { asset: i_token, amount: _ameowntToWhiskdraw, to: address(this) } );
    }

    // This function is expected to get userVaultCollateralInEuros
    // the result is returned as a uint256 value
    function getUserVaultMeowllateralInEuros(address _user) external view returns (uint256) {
        // Here the latestRoundData function call gets the latest priceFeed
        // The second value returned  by the function latestRoundData is assigned to collateralToUsdPrice  
        (, int256 collateralToUsdPrice, , , ) = i_priceFeed.latestRoundData();
        // Here, the latestRoundData function call gets the latest euroPriceFeed
        // the second value returned is then assigned to euroPriceFeedAns as a int256 value
        (, int256 euroPriceFeedAns, , ,) = i_euroPriceFeed.latestRoundData();
        // This line calculates the user's Meowllateral 
        // by performing mulDiv
        // converting collateralToUsdPrice to a uint256 value
        // multiply the price by extra decimals and precisions
        // assigning the value to collateralAns
        uint256 collateralAns = getUserMeowllateral(_user).mulDiv(uint256(collateralToUsdPrice) * EXTRA_DECIMALS, PRECISION);
        // Here you return the result of collateralAns
        // after performing the mulDiv by 
        // the euroPriceFeedAns value in uint256
        // multiply the price by extra decimals and precision
        // the final returned result will then be the user's meowllateral in euros
        return collateralAns.mulDiv(uint256(euroPriceFeedAns) * EXTRA_DECIMALS, PRECISION);
    }

    // This function is expected to get the user collateral
    // The expected user collateral is returned as a uint256 value
    function getUserMeowllateral(address _user) public view returns (uint256) {
        // Here the variable is assigned a value
        uint256 totalMeowllateralOfVault = getTotalMeowllateral();
        // Here is expected to 
        // Retrieve the user's balance of cattyNip from the userToCattyNip mapping.
        // Multiply the balance by totalMeowllateralOfVault
        // Divide the result by total supply of cattyNip
        // Then return the final value calculated
        return userToCattyNip[_user].mulDiv(totalMeowllateralOfVault, totalCattyNip);
    }

    // This function is expected to calculate the sum of the collateral
    // And return the total collateral in vault
    // The combined total is returned as a uint256 value.
    function getTotalMeowllateral() public view returns (uint256) {
        return totalMeowllateralInVault + getTotalMeowllateralInAave();
    }

    function getTotalMeowllateralInAave() public view returns (uint256) {
        // @audit-lead verify what the function does
        // i expect to fetch user data from aavePool

        // Here, the first value of uint256 totalCollateralBase is being stored.
        // The commas indicate that the remaining returned values are being ignored.
        // The line retrieves the total collateral for the current contract in Aave (stored in totalCollateralBase) 
        // by calling the getUserAccountData function from Aave's pool contract. 
        (uint256 totalCollateralBase, , , , , ) = i_aavePool.getUserAccountData(address(this));
        
        // Here, only the second value of collateralToUsdPrice is captured
        // the commas indicate that the other values returned by the function are being ignored.
        // then the function latestRoundData is called on the i_priceFeed contract to get the latest price information.
        (, int256 collateralToUsdPrice, , , ) = i_priceFeed.latestRoundData();

        // Here, is meant to return the result of the function when mulDiv operation is carried out
        // converting collateralToUsdPrice to uint256 value
        // multiply the price by extra decimals
        return totalCollateralBase.mulDiv(PRECISION, uint256(collateralToUsdPrice) * EXTRA_DECIMALS);
    }
}