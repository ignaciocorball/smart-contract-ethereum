# UFChain Smart Contract

## Overview

UFChain is an ERC-20 smart contract implemented in Solidity v0.8.20 that represents the native **UFC** (UFChain) token. This contract implements the ERC-20 standard with additional access control and trading management features.

## Key Features

### 🪙 Token Information
- **Name**: UFChain
- **Symbol**: UFC
- **Decimals**: 18
- **Total Supply**: 10,000,000,000 UFC (10 billion)
- **Standard**: ERC-20

### 🔐 Security Features

#### 1. Whitelist System
- The contract includes a whitelist system that allows the owner to control which addresses can perform transactions before trading is enabled.
- Whitelisted addresses can transfer tokens even when trading is disabled.

#### 2. Trading Control
- Trading starts **disabled** by default.
- Only the owner can enable trading through the `enableTrading()` function.
- **Important**: Once enabled, trading **CANNOT be disabled**.

#### 3. Ownership
- Implements the Ownable pattern for access control.
- The initial owner is set in the constructor.
- The owner can transfer ownership or renounce it.

## Main Functions

### Standard ERC-20 Functions
```solidity
function transfer(address recipient, uint256 amount) external returns (bool)
function transferFrom(address sender, address recipient, uint256 amount) external returns (bool)
function approve(address spender, uint256 amount) external returns (bool)
function allowance(address owner, address spender) external view returns (uint256)
function balanceOf(address account) external view returns (uint256)
function totalSupply() external view returns (uint256)
```

### Additional Functions

#### `enableTrading()`
- **Access**: Owner only
- **Description**: Enables token trading permanently
- **Note**: This action is irreversible

#### `setWhitelist(address _user, bool _status)`
- **Access**: Owner only
- **Description**: Adds or removes an address from the whitelist
- **Parameters**:
  - `_user`: Address to modify
  - `_status`: `true` to add, `false` to remove

#### `increaseAllowance(address spender, uint256 addedValue)`
- **Description**: Safely increases token allowance

#### `decreaseAllowance(address spender, uint256 subtractedValue)`
- **Description**: Safely decreases token allowance

## Events

```solidity
event Transfer(address indexed from, address indexed to, uint256 value)
event Approval(address indexed owner, address indexed spender, uint256 value)
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
event WhitelistUpdated(address indexed user, bool status)
```

## Transfer Logic

### Transfer Conditions
1. **Valid addresses**: Neither sender nor recipient can be the zero address
2. **Valid amount**: Amount must be greater than zero
3. **Sufficient balance**: Sender must have sufficient balance
4. **Trading control**: 
   - If both addresses are whitelisted: transfer allowed
   - If any address is NOT whitelisted: requires trading to be enabled

### Validation Flow
```
Are From and To whitelisted?
├── YES → Transfer allowed
└── NO → Is trading enabled?
    ├── YES → Transfer allowed
    └── NO → Transfer rejected
```

## Security and Considerations

### ✅ Security Features
- Protection against zero addresses
- Amount validation
- Overflow/underflow protection (Solidity 0.8.20+)
- Ownable pattern for access control
- Safe increase/decrease allowance functions

### ⚠️ Important Considerations
- **Irreversible trading**: Once enabled, cannot be disabled
- **Temporary whitelist**: Whitelist only works before enabling trading
- **Initial concentration**: All supply is assigned to the initial owner

## Deployment

### Constructor
```solidity
constructor(address initialOwner)
```

The constructor requires:
- `initialOwner`: Address that will be the initial contract owner

### Initial State
- All supply (10B UFC) is assigned to the owner
- The deployer is automatically added to the whitelist
- Trading starts disabled

## Use Cases

1. **Pre-Trading Phase**: Controlled distribution to specific addresses through whitelist
2. **Post-Trading Phase**: Free trading once enabled
3. **Access Management**: Granular control of which addresses can operate in each phase

## Compiler Version

- **Solidity**: ^0.8.20
- **License**: MIT

## Technical Notes

- Implements standard IERC20 interfaces
- Uses implicit SafeMath from Solidity 0.8.20+
- Gas-optimized for common operations
- Compatible with standard wallets and exchanges

---

**Important**: This contract is designed for a controlled launch where tokens are distributed to specific addresses before enabling public trading. Once trading is enabled, the behavior becomes equivalent to a standard ERC-20 token.