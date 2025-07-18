// SPDX-License-Identifier: MIT

/*
    _   _ _____ ____ _   _    _    ___ _   _ 
   | | | |  ___/ ___| | | |  / \  |_ _| \ | |
   | | | | |_ | |   | |_| | / _ \  | ||  \| |
   | |_| |  _|| |___|  _  |/ ___ \ | || |\  |
    \___/|_|   \____|_| |_/_/   \_\___|_| \_|                                       
*/

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        require(initialOwner != address(0), "Ownable: Invalid owner address");
        _owner = initialOwner;
        emit OwnershipTransferred(address(0), initialOwner);
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: Invalid owner address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

/**
 * @dev Implementation of the UFChain ERC-20 token contract.
 * 
 * This contract implements the ERC-20 standard with additional features:
 * - Whitelist functionality for trading restrictions
 * - Trading enable/disable mechanism
 * - Owner-controlled operations
 */
contract UFChain is Context, IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public whitelist;

    string private _name = "UFChain";
    string private _symbol = "UFC";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 10_000_000_000 * 1e18; // Max Total Supply

    bool public trading; // once this is enabled, it cannot be disabled.

    event WhitelistUpdated(address indexed user, bool status);

    /**
     * @dev Constructor that initializes the contract with the initial owner.
     * @param initialOwner The address that will be set as the initial owner.
     */
    constructor(address initialOwner) Ownable(initialOwner) {
        whitelist[msg.sender] = true;
        _balances[owner()] = _totalSupply;
        
        emit Transfer(address(0), owner(), _totalSupply);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the total supply of tokens.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}.
     */
    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits an {Approval} event.
     */
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     */
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     */
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public returns (bool) {
        require(
            _allowances[_msgSender()][spender] >= subtractedValue,
            "UFChain: decreased allowance below zero"
        );
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - subtractedValue
        );
        return true;
    }

    /**
     * @dev Enables trading for the token. This function can only be called by the owner
     * and once enabled, trading cannot be disabled.
     */
    function enableTrading() external onlyOwner {
        require(!trading, "UFChain: Trading is already enabled");
        trading = true;
    }

    /**
     * @dev Allows the owner to add or remove an address from the whitelist.
     * The whitelist is used to exempt certain addresses from trading restrictions.
     *
     * Important Notes:
     *  - Once trading is enabled, it cannot be disabled again.
     *  - After trading is enabled, the whitelist will no longer affect transfer behavior.
     *
     * @param _user The address to be added to or removed from the whitelist.
     * @param _status A boolean indicating whether the address should be added (`true`) or removed (`false`) from the whitelist.
     */
    function setWhitelist(address _user, bool _status) external onlyOwner {
        whitelist[_user] = _status;
        emit WhitelistUpdated(_user, _status);
    }

    /**
     * @dev Internal function to approve spending of tokens.
     * @param owner The address that owns the tokens.
     * @param spender The address that will spend the tokens.
     * @param amount The amount of tokens to approve.
     */
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "UFChain: Approve from zero address");
        require(spender != address(0), "UFChain: Approve to zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Internal function to handle the transfer of tokens between two addresses.
     * This function is private and is called internally by other public functions like `transfer` and `transferFrom`.
     *
     * The function ensures:
     *  - Neither the sender (`from`) nor the recipient (`to`) is the zero address.
     *  - The transfer amount is greater than zero.
     *  - Trading is enabled for non-whitelisted addresses.
     *  - The sender has a sufficient balance to complete the transfer.
     *
     * @param from The address sending the tokens.
     * @param to The address receiving the tokens.
     * @param amount The number of tokens to transfer.
     */
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "UFChain: Transfer from zero address");
        require(to != address(0), "UFChain: Transfer to zero address");
        require(amount > 0, "UFChain: Transfer amount must be greater than zero");

        if (!whitelist[from] && !whitelist[to]) {
            require(trading, "UFChain: Trading is disabled");
        }

        uint256 senderBalance = _balances[from];
        require(senderBalance >= amount, "UFChain: Insufficient balance");

        _balances[from] -= amount;
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }
}
