// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.16;

/// @dev Thrown if not beacon root found for given timestamp.
error NoBeaconRootFound();

/**
 * @title BeaconRoots
 *
 * @notice Library for the EIP-4788 beacon roots system contract
 *
 * @dev The beacon roots system contract provides access to the last 8191 beacon
 *      roots.
 *
 * @custom:references
 *      - [EIP-4788]: https://eips.ethereum.org/EIPS/eip-4788
 *
 * @author verklegarden
 * @custom:repository github.com/verklegarden/syslib
 */
library BeaconRoots {
    /// @dev The beacon root system contract address.
    address internal constant SYSTEM_CONTRACT =
        0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02;

    /// @dev Reads the beacon root at timestamp `timestamp` from the system
    ///      contract.
    function tryGet(uint timestamp) internal view returns (bytes32, bool) {
        if (timestamp == 0 || timestamp >= block.timestamp) {
            return (0, false);
        }

        bool ok;
        bytes memory data;
        (ok, data) = SYSTEM_CONTRACT.staticcall(abi.encodePacked(timestamp));
        if (!ok) {
            return (bytes32(0), false);
        }
        // assert(data.length == 32);

        bytes32 root = abi.decode(data, (bytes32));
        return (root, true);
    }

    /// @dev Reads the beacon root at timestamp `timestamp` from the system
    ///      contract.
    ///
    /// @dev Reverts if:
    ///      - No beacon root found for given timestamp
    function get(uint timestamp) internal view returns (bytes32) {
        bytes32 root;
        bool ok;
        (root, ok) = tryGet(timestamp);
        if (!ok) {
            revert NoBeaconRootFound();
        }

        return root;
    }
}
