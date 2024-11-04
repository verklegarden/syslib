// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.16;

/// @dev Thrown if request payload's length invalid.
error PayloadLengthInvalid();

/// @dev Thrown if fee insufficient for
error InsufficientFee();

/**
 * @title Withdrawals
 *
 * @notice Library for the EIP-7002 withdrawals system contract
 *
 * @dev The withdrawals system contract allows validators to trigger exits and
 *      partial withdrawals. In order to prevent spamming a fee must be paid for
 *      each request.
 *
 * @custom:references
 *      - [EIP-7002]: https://eips.ethereum.org/EIPS/eip-7002
 *
 * @author verklegarden
 * @custom:repository github.com/verklegarden/syslib
 */
library Withdrawals {
    uint private constant _FACTOR = 1;
    uint private constant _DENOMINATOR = 17;

    // TODO: Update to actual address once deployed.
    /// @dev The withdrawals system contract address.
    address internal constant SYSTEM_CONTRACT =
        0x000000000000000000000000000000000000cafE;

    /// @dev The size of the payload for a withdrawal request.
    uint internal constant PAYLOAD_SIZE = 56;

    /// @dev Requests withdrawal for public key and amount `payload`.
    ///
    /// @dev Note that requesting a withdrawal costs a fee.
    ///
    /// @dev Reverts if:
    ///      - Payload's length not PAYLOAD_SIZE
    ///      - Caller's balance insufficient to pay fee
    function request(bytes memory payload) internal {
        requestWithFee(payload, computeFee());
    }

    /// @dev Requests withdrawal for public key and amount `payload` with fee
    ///      `fee`.
    ///
    /// @dev Reverts if:
    ///      - Payload's length not PAYLOAD_SIZE
    ///      - Caller's balance insufficient to pay fee
    ///      - Fee insufficient
    function requestWithFee(bytes memory payload, uint fee) internal {
        if (payload.length != PAYLOAD_SIZE) {
            revert PayloadLengthInvalid();
        }

        bool ok;
        bytes memory data;
        (ok, data) = SYSTEM_CONTRACT.call{value: fee}(payload);
        if (!ok) {
            // Note that call reverts, after the respective fork number, iff the
            // given fee is insufficient.
            revert InsufficientFee();
        }
        assert(data.length == 0);
    }

    /// @dev Reads the current excess value from the system contract.
    ///
    /// @dev The excess value defines the current fee to add a consolidation
    ///      request.
    function getExcess() internal view returns (uint) {
        bool ok;
        bytes memory data;
        (ok, data) = SYSTEM_CONTRACT.staticcall(hex"");
        assert(ok);
        assert(data.length == 32);

        return abi.decode(data, (uint));
    }

    /// @dev Computes the current fee for a consolidation request.
    function computeFee() internal view returns (uint) {
        return _fakeExpo(getExcess());
    }

    // -- Private Helpers --

    /// @dev Computes the system contract's request fee given its excess value
    ///      `excess`.
    function _fakeExpo(uint excess) private pure returns (uint) {
        // Implemented in assembly to circumvent div-by-zero protection.
        //
        // Note that possible overflow is accepted.
        //
        // Functionally equivalent Solidity code:
        //
        //   unchecked {
        //      uint i = 1;
        //      uint output = 0;
        //      uint numerator_accum = _FACTOR * _DENOMINATOR;
        //      while (numerator_accum > 0) {
        //        output += numerator_accum;
        //        numerator_accum = (numerator_accum * numerator) / (_DENOMINATOR * i);
        //        i += 1;
        //      }
        //      return output / _DENOMINATOR;
        //   }
        uint numerator = excess;
        uint result;
        assembly ("memory-safe") {
            let i := 1
            let output := 0
            let numerator_accum := mul(_FACTOR, _DENOMINATOR)

            for {} gt(numerator_accum, 0) {} {
                output := add(output, numerator_accum)
                numerator_accum :=
                    div(mul(numerator_accum, numerator), mul(_DENOMINATOR, i))
                i := add(i, 1)
            }

            result := div(output, _DENOMINATOR)
        }
        return result;
    }
}
