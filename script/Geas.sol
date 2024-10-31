// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.16;

import {Vm} from "forge-std/Vm.sol";

/**
 * @title Geas
 *
 * @notice Library to compile geas programs
 *
 * @author verklegarden
 * @custom:repository github.com/verklegarden/syslib
 */
library Geas {
    Vm private constant vm =
        Vm(address(uint160(uint(keccak256("hevm cheat code")))));

    /// @dev Compiles geas program at path `path` and returns its bytecode.
    function compile(string memory path) internal returns (bytes memory) {
        string[] memory args = new string[](3);
        args[0] = "geas";
        args[1] = "-no-nl";
        args[2] = path;

        return vm.ffi(args);
    }
}
