// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.16;

/// @dev Thrown if not execution hash found for given block number.
error NoExecutionHashFound();

/**
 * @title ExecutionHashes
 *
 * @notice Library for the EIP-2935 execution hashes system contract
 *
 * @dev The execution hashes system contract provides access to the last 8191
 *      execution block hashes.
 *
 *      Note that this library automatically uses the cheaper `blockhash` opcode
 *      if suitable.
 *
 * @custom:references
 *      - [EIP-2935]: https://eips.ethereum.org/EIPS/eip-2935
 *
 * @author verklegarden
 * @custom:repository github.com/verklegarden/syslib
 */
library ExecutionHashes {
    // TODO: Update to actual address once deployed.
    /// @dev The execution hashes system contract address.
    address internal constant SYSTEM_CONTRACT =
        0x000000000000000000000000000000000000cafE;

    /// @dev Returns the execution hash of block `number`.
    function tryGet(uint number) internal view returns (bytes32, bool) {
        if (number >= block.number) {
            return (0, false);
        }

        if (number >= block.number - 1 - 256) {
            return (blockhash(number), true);
        }

        bool ok;
        bytes memory data;
        (ok, data) = SYSTEM_CONTRACT.staticcall(abi.encodePacked(number));
        if (!ok) {
            return (0, false);
        }
        // assert(data.length == 32);

        return (abi.decode(data, (bytes32)), true);
    }

    /// @dev Returns the execution hash of block `number`.
    ///
    /// @dev Reverts if:
    ///      - No execution hash found for given number
    function get(uint number) internal view returns (bytes32) {
        bytes32 hash_;
        bool ok;
        (hash_, ok) = tryGet(number);
        if (!ok) {
            revert NoExecutionHashFound();
        }

        return hash_;
    }
}
