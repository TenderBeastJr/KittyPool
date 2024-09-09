// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import { KittyCoin } from "./KittyCoin.sol";
import { KittyVault, IKittyVault } from "./KittyVault.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

contract KittyPool {
    using Math for uint256;

    error KittyPool__NotMeowntainerPurrrrr();
    error KittyPool__TokenNotFoundMeeoooww();
    error KittyPool__NotEnoughMeowllateralPurrrr();
    error KittyPool__TokenAlreadyExistsMeeoooww();
    error KittyPool__UserIsPurrfect();

    address private meowntainer;
    mapping(address token => address vault) private tokenToVault;
    address[] private vaults;
    KittyCoin private immutable i_kittyCoin;
    address private immutable i_euroPriceFeed;
    address private immutable i_aavePool;
    mapping(address user => uint256 debt) private kittyCoinMeownted;

    uint256 private constant COLLATERAL_PERCENT = 169;
    uint256 private constant COLLATERAL_PRECISION = 100;
    uint256 private constant REWARD_PERCENT = 0.05e18;
    uint256 private constant PRECISION = 1e18;

    modifier onlyMeowntainer() {
        require(msg.sender == meowntainer, KittyPool__NotMeowntainerPurrrrr());
        _;
    }

    modifier tokenExists(address _token) {
        require(tokenToVault[_token] != address(0), KittyPool__TokenNotFoundMeeoooww());
        _;
    }
    

    constructor(address _meowntainer, address _euroPriceFeed, address aavePool) {
        meowntainer = _meowntainer;
        i_kittyCoin = new KittyCoin(address(this));
        i_euroPriceFeed = _euroPriceFeed;
        i_aavePool = aavePool;
    }


    function meownufactureKittyVault(address _token, address _priceFeed) external onlyMeowntainer {
        require(tokenToVault[_token] == address(0), KittyPool__TokenAlreadyExistsMeeoooww());

        address _kittyVault = address(new KittyVault{ salt: bytes32(abi.encodePacked(ERC20(_token).symbol())) }(_token, address(this), _priceFeed, i_euroPriceFeed, meowntainer, i_aavePool));

        tokenToVault[_token] = _kittyVault;
        vaults.push(_kittyVault);
    } 


    function depawsitMeowllateral(address _token, uint256 _ameownt) external tokenExists(_token) {
        IKittyVault(tokenToVault[_token]).executeDepawsit(msg.sender, _ameownt);
    } 

    function whiskdrawMeowllateral(address _token, uint256 _ameownt) external tokenExists(_token) {
        IKittyVault(tokenToVault[_token]).executeWhiskdrawal(msg.sender, _ameownt);
        require(_hasEnoughMeowllateral(msg.sender), KittyPool__NotEnoughMeowllateralPurrrr());
    }

    function meowintKittyCoin(uint256 _ameownt) external {
        kittyCoinMeownted[msg.sender] += _ameownt;
        i_kittyCoin.mint(msg.sender, _ameownt);
        require(_hasEnoughMeowllateral(msg.sender), KittyPool__NotEnoughMeowllateralPurrrr());
    }


    function burnKittyCoin(address _onBehalfOf, uint256 _ameownt) external {
        kittyCoinMeownted[_onBehalfOf] -= _ameownt;
        i_kittyCoin.burn(msg.sender, _ameownt);
    }

    function purrgeBadPawsition(address _user) external returns (uint256 _totalAmountReceived) {
        require(!(_hasEnoughMeowllateral(_user)), KittyPool__UserIsPurrfect());
        uint256 totalDebt = kittyCoinMeownted[_user];

        kittyCoinMeownted[_user] = 0;
        i_kittyCoin.burn(msg.sender, totalDebt);

        uint256 userMeowllateralInEuros = getUserMeowllateralInEuros(_user);

        uint256 redeemPercent;

        if (totalDebt >= userMeowllateralInEuros) {
            redeemPercent = PRECISION;
        }
        else {
            redeemPercent = totalDebt.mulDiv(PRECISION, userMeowllateralInEuros);
        }

        uint256 vaults_length = vaults.length;

        for (uint256 i; i < vaults_length; ) {
            IKittyVault _vault = IKittyVault(vaults[i]);
            uint256 vaultCollateral = _vault.getUserVaultMeowllateralInEuros(_user);
            uint256 toDistribute = vaultCollateral.mulDiv(redeemPercent, PRECISION);
            uint256 extraCollateral = vaultCollateral - toDistribute;

            uint256 extraReward = toDistribute.mulDiv(REWARD_PERCENT, PRECISION);
            extraReward = Math.min(extraReward, extraCollateral);
            _totalAmountReceived += (toDistribute + extraReward);

            _vault.executeWhiskdrawal(msg.sender, toDistribute + extraReward);

            unchecked {
                ++i;
            }
        }
    }

    function _hasEnoughMeowllateral(address _user) internal view returns (bool hasEnoughCollateral) {
        uint256 totalCollateralInEuros = getUserMeowllateralInEuros(_user);
        uint256 collateralRequiredInEuros = kittyCoinMeownted[_user].mulDiv(COLLATERAL_PERCENT, COLLATERAL_PRECISION);

        return totalCollateralInEuros >= collateralRequiredInEuros;
    }

    function getUserMeowllateralInEuros(address _user) public view returns (uint256 totalUserMeowllateral) {
        uint256 vault_length = vaults.length;

        for (uint256 i; i < vault_length; ) {
            totalUserMeowllateral += IKittyVault(vaults[i]).getUserVaultMeowllateralInEuros(_user);

            unchecked {
                ++i;
            }
        }
    }

    function getAavePool() external view returns (address) {
        return i_aavePool;
    }

    function getMeowntainer() external view returns (address) {
        return meowntainer;
    }

    function getKittyCoin() external view returns (address) {
        return address(i_kittyCoin);
    }

    function getTokenToVault(address _token) external view returns (address) {
        return tokenToVault[_token];
    }

    function getKittyCoinMeownted(address _user) external view returns (uint256) {
        return kittyCoinMeownted[_user];
    }
}