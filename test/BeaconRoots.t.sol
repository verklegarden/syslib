// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import {console2 as console} from "forge-std/console2.sol";

import {BeaconRoots} from "../src/BeaconRoots.sol";

import {Geas} from "../script/Geas.sol";

contract BeaconRootsTest is Test {
    uint constant BUFFER_SIZE = 8191;

    function setUp() public {
        vm.etch(
            BeaconRoots.SYSTEM_CONTRACT,
            Geas.compile("lib/sys-asm/src/beacon_root/main.eas")
        );
    }

    function testFuzz_tryGet() public {
        vm.skip(true);
    }

    function testFuzz_get() public {
        vm.skip(true);
    }

    // -- Private Helpers --
}
