// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import {console2 as console} from "forge-std/console2.sol";

import {ExecutionHashes} from "../src/ExecutionHashes.sol";

import {Geas} from "../script/Geas.sol";

contract ExecutionHashesTest is Test {
    uint constant RING_BUFFER_SIZE = 8191;

    function setUp() public {
        bytes memory code =
            Geas.compile("lib/sys-asm/src/execution_hash/main.eas");

        vm.etch(ExecutionHashes.SYSTEM_CONTRACT, code);
    }

    function testFuzz_tryGet() public {
        vm.skip(true);
    }

    function testFuzz_get() public {
        vm.skip(true);
    }
}
