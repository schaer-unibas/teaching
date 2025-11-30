// SPDX-License-Identifier: MIT
// Code for teaching purposes only.
// See University of Basel cryptolectures.io

pragma solidity ^0.8.9;

/* ===========================
   ERC20 LP Token (simplified)
   =========================== */
contract LPToken {
    // ERC-20 metadata
    string public constant name = "LP Token";
    string public constant symbol = "LPT";
    uint8  public constant decimals = 18;

    // Total supply
    uint256 public totalSupply;

    // Balances and allowances
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Authorized minter (the vault)
    address public immutable minter;

    // ERC-20 events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Restrict to the vault
    modifier onlyMinter() {
        require(msg.sender == minter, "These are not the droids you are looking for!");
        _;
    }

    constructor(address _minter) {
        require(_minter != address(0), "Minter is zero");
        minter = _minter;
    }

    // Standard ERC-20 functions
    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        require(allowed >= value, "Allowance exceeded");
        if (allowed != type(uint256).max) {
            allowance[from][msg.sender] = allowed - value;
            emit Approval(from, msg.sender, allowance[from][msg.sender]);
        }
        _transfer(from, to, value);
        return true;
    }

    // Mint and burn controlled by the vault
    function mint(address to, uint256 value) external onlyMinter {
        totalSupply += value;
        balanceOf[to] += value;
        emit Transfer(address(0), to, value);
    }

    // The vault can burn from any address when redeeming
    function burnFrom(address from, uint256 value) external onlyMinter {
        require(balanceOf[from] >= value, "Insufficient balance");
        balanceOf[from] -= value;
        totalSupply -= value;
        emit Transfer(from, address(0), value);
    }

    // Internal transfer, slightly more complex implementation of ERC20 than simple token.
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "Transfer to zero");
        require(balanceOf[from] >= value, "Insufficient balance");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
    }
}

/* ==========================================
   Vault: deposit ETH <-> mint/burn LP tokens
   ========================================== */
contract SimpleLPVault {
    // 1 ETH mints 1000 LPT
    uint256 public constant RATE = 1000;

    // LP token instance
    LPToken public immutable lpToken;

    constructor() {
        // Deploy the LP token with this contract as the minter
        lpToken = new LPToken(address(this));
    }

    // Deposit ETH and receive LPT at the fixed rate
    function deposit() public payable {
        require(msg.value > 0, "No ETH sent");
        // With 18 decimals on both ETH and LPT, this gives 1000 LPT per 1 ETH
        uint256 mintAmount = msg.value * RATE;
        lpToken.mint(msg.sender, mintAmount);
    }

    // Redeem LPT for ETH at the same fixed rate
    function redeem(uint256 lptAmount) public {
        require(lptAmount > 0, "Zero amount");
        uint256 ethAmount = lptAmount / RATE;
        require(ethAmount > 0, "Amount too small");
        require(address(this).balance >= ethAmount, "Insufficient ETH in vault");

        // Burn first, then transfer ETH
        lpToken.burnFrom(msg.sender, lptAmount);

        (bool ok, ) = msg.sender.call{value: ethAmount}("");
        require(ok, "ETH transfer failed");
    }

    // Student classroom view functions
    function previewDeposit(uint256 ethAmount) public pure returns (uint256) {
        return ethAmount * RATE;
    }

    function previewRedeem(uint256 lptAmount) public pure returns (uint256) {
        return lptAmount / RATE;
    }

    // Accept plain ETH transfers (e.g., from self-destruct)
    receive() external payable {}
}
