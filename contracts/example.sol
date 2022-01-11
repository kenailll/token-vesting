/**
 *Submitted for verification at BscScan.com on 2021-12-17
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

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
    ) external returns (bool);

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
}


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for BEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IBEP20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0), "SafeBEP20: approve from non-zero to non-zero allowance");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeBEP20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeBEP20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

contract BEP20Vesting is Context{
    // Contract libs
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    // Contract events
    event Released(address indexed beneficiary, uint256 amount);

    // Vesting information struct
    struct VestingBeneficiary {
        address beneficiary;
        uint256 lockDuration;
        uint256 duration;
        uint256 amount;
        uint256 leftOverVestingAmount;
        uint256 released;
        uint256 upfrontAmount;
        uint256 startedAt;
        uint256 interval;
        uint256 lastReleasedAt;
    }

    IBEP20 public token;
    // Vesting beneficiary list
    mapping(address => VestingBeneficiary) public beneficiaries;
    address[] public beneficiaryAddresses;
    // Token deployed date
    uint256 public tokenListingDate;
    uint256 public tokenVestingCap;

    constructor(address _token, uint256 _tokenListingDate) public{
        require(_token != address(0), "The token's address cannot be 0");
        token = IBEP20(_token);
        if (_tokenListingDate > 0) {
            tokenListingDate = _tokenListingDate;
        }

        //todo：添加受益者
        addBeneficiary(0x0AEB49BBCE2D6798c5EF718cc460c1dD3f430BB2,6000000000000,7948800,38880000,0,7776000);
        addBeneficiary(0xC792E1612319Ba94c078D860848eb3c305883458,16200000000000,7948800,38880000,0,7776000);
        addBeneficiary(0xA37E3a062e48CCb3560919d63DE6A29Cfc347476,30000000000000,7948800,38880000,0,7776000);
        addBeneficiary(0xA608FE94cC2397bB019bf642D7CF65BCcB26D370,45000000000000,15724800,0,0,0);
        addBeneficiary(0xbEd23eE50eD036cFa3986B4DB8B5E4721a200CB3,30000000000000,15811200,38880000,0,7776000);
        addBeneficiary(0xc58407B81f62553D1f371F2456c548aB1F82E150,60000000000000,7948800,0,0,0);
        addBeneficiary(0x52Ee965c22a482b37D0c5C4F4C67B2F921dFbaB7,30000000000000,15724800,0,0,0);
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
    ) internal {
        require(
            _beneficiary != address(0),
            "The beneficiary's address cannot be 0"
        );

        require(_amount > 0, "Shares amount has to be greater than 0");
        require(
            tokenVestingCap.add(_amount) <= token.totalSupply(),
            "Full token vesting to other beneficiaries. Can not add new beneficiary"
        );
        require(
            beneficiaries[_beneficiary].amount == 0,
            "The beneficiary has added to the vesting pool already"
        );

        // Add new vesting beneficiary
        uint256 _leftOverVestingAmount = _amount.sub(_upfrontAmount);
        uint256 vestingStartedAt = tokenListingDate.add(_lockDuration);
        beneficiaries[_beneficiary] = VestingBeneficiary(
            _beneficiary,
            _lockDuration,
            _duration,
            _amount,
            _leftOverVestingAmount,
            0,
            _upfrontAmount,
            vestingStartedAt,
            _interval,
            0
        );

        beneficiaryAddresses.push(_beneficiary);
        tokenVestingCap = tokenVestingCap.add(_amount);
    }

    /**
     * @dev Get new vested amount of beneficiary base on vesting schedule of this beneficiary.
     */
    function releasableAmount(address _beneficiary)
    public
    view
    returns (
        uint256,
        uint256,
        uint256
    )
    {
        if (beneficiaries[_beneficiary].amount == 0) {
            return (0, 0, block.timestamp);
        }

        (uint256 _vestedAmount, uint256 _lastIntervalDate) = vestedAmount(
            _beneficiary
        );

        return (
        _vestedAmount,
        _vestedAmount.sub(beneficiaries[_beneficiary].released),
        _lastIntervalDate
        );
    }

    /**
     * @dev Get total vested amount of beneficiary base on vesting schedule of this beneficiary.
     */
    function vestedAmount(address _beneficiary)
    public
    view
    returns (uint256, uint256)
    {
        require(beneficiaries[_beneficiary].amount > 0, "The beneficiary's address cannot be found");
        // Listing date is not set
        if (beneficiaries[_beneficiary].startedAt == 0) {
            return (beneficiaries[_beneficiary].released, beneficiaries[_beneficiary].lastReleasedAt);
        }

        // Transfer immediately if any upfront amount
        if (beneficiaries[_beneficiary].upfrontAmount > 0 && beneficiaries[_beneficiary].released == 0) {
            return (beneficiaries[_beneficiary].upfrontAmount, 0);
        }

        // No vesting (All amount unlock at the TGE)
        if (beneficiaries[_beneficiary].duration == 0) {
            return (beneficiaries[_beneficiary].amount, beneficiaries[_beneficiary].startedAt);
        }

        // Vesting has not started yet
        if (block.timestamp < beneficiaries[_beneficiary].startedAt) {
            return (beneficiaries[_beneficiary].released, beneficiaries[_beneficiary].lastReleasedAt);
        }

        // Vesting is done
        if (block.timestamp >= beneficiaries[_beneficiary].startedAt.add(beneficiaries[_beneficiary].duration)) {
            return (beneficiaries[_beneficiary].amount, beneficiaries[_beneficiary].startedAt.add(beneficiaries[_beneficiary].duration));
        }

        // It's too soon to next release
        if (
            beneficiaries[_beneficiary].lastReleasedAt > 0 &&
            block.timestamp < beneficiaries[_beneficiary].interval + beneficiaries[_beneficiary].lastReleasedAt
        ) {
            return (beneficiaries[_beneficiary].released, beneficiaries[_beneficiary].lastReleasedAt);
        }

        // Vesting is interval counter
        uint256 totalVestedAmount = beneficiaries[_beneficiary].released;
        uint256 lastIntervalDate = beneficiaries[_beneficiary].lastReleasedAt > 0
        ? beneficiaries[_beneficiary].lastReleasedAt
        : beneficiaries[_beneficiary].startedAt;

        uint256 multiplyIntervals;
        while (block.timestamp >= lastIntervalDate.add(beneficiaries[_beneficiary].interval)) {
            multiplyIntervals = multiplyIntervals.add(1);
            lastIntervalDate = lastIntervalDate.add(beneficiaries[_beneficiary].interval);
        }

        if (multiplyIntervals > 0) {
            uint256 newVestedAmount = beneficiaries[_beneficiary]
            .leftOverVestingAmount
            .mul(multiplyIntervals.mul(beneficiaries[_beneficiary].interval))
            .div(beneficiaries[_beneficiary].duration);

            totalVestedAmount = totalVestedAmount.add(newVestedAmount);
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
        beneficiaries[_beneficiary].released = beneficiaries[_beneficiary].released.add(_amount);
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
        ,
        uint256 _newReleaseAmount,
        uint256 _lastIntervalDate
        ) = releasableAmount(_msgSender());

        // Release new vested token to the beneficiary
        if (_newReleaseAmount > 0) {
            releaseTo(_msgSender(), _newReleaseAmount, _lastIntervalDate);
        }
    }
}