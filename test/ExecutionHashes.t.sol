// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import {console2 as console} from "forge-std/console2.sol";

import {
    ExecutionHashes, NoExecutionHashFound
} from "../src/ExecutionHashes.sol";

import {Geas} from "../script/Geas.sol";

contract ExecutionHashesTest is Test {
    uint constant BUFFER_SIZE = 8191;

    function setUp() public {
        vm.etch(
            ExecutionHashes.SYSTEM_CONTRACT,
            Geas.compile("lib/sys-asm/src/execution_hash/main.eas")
        );
    }

    // -- Test: tryGet --

    function testFuzz_tryGet(uint number, uint seed) public {
        vm.assume(number != 0);
        vm.assume(number - 1 > BUFFER_SIZE);

        // Create valid query from seed.
        //
        // A valid query is in [number - 1 - BUFFER_SIZE, number - 1].
        uint query = _bound(seed, number - 1 - BUFFER_SIZE, number - 1);

        // Roll to number.
        vm.roll(number);

        // Let system contract have random storage.
        vm.setArbitraryStorage(ExecutionHashes.SYSTEM_CONTRACT);

        // Let block hash of query be zero.
        // This value is returned if the blockhash() optimization is utilized.
        vm.setBlockhash(query, bytes32(0));

        // Read block hash from system contract.
        (bytes32 got, bool ok) = ExecutionHashes.tryGet(query);
        assertTrue(ok);

        // The expected block hash is either the result of blockhash() or the
        // value at storage slot query % BUFFER_SIZE.
        bytes32 want;
        if (query >= number - 1 - 256) {
            want = blockhash(query);
        } else {
            want = vm.load(
                ExecutionHashes.SYSTEM_CONTRACT, bytes32(query % BUFFER_SIZE)
            );
        }
        assertEq(want, got);
    }

    function testFuzz_tryGet_Boundaries(uint number) public {
        vm.assume(number > BUFFER_SIZE + 2);

        // Roll to number.
        vm.roll(number);

        bool ok;

        // Fails for number.
        (, ok) = ExecutionHashes.tryGet(number);
        assertFalse(ok);

        // Does not fail for number - 1.
        (, ok) = ExecutionHashes.tryGet(number - 1);
        assertTrue(ok);

        // Does not fail for number - 1 - BUFFER_SIZE.
        (, ok) = ExecutionHashes.tryGet(number - 1 - BUFFER_SIZE);
        assertTrue(ok);

        // Fails for number - 1 - BUFFER_SIZE - 1.
        (, ok) = ExecutionHashes.tryGet(number - 1 - BUFFER_SIZE - 1);
        assertFalse(ok);
    }

    // -- Test: get --

    function testFuzz_get(uint number, uint seed) public {
        vm.assume(number != 0);
        vm.assume(number - 1 > BUFFER_SIZE);

        // Create valid query from seed.
        //
        // A valid query is in [number - 1 - BUFFER_SIZE, number - 1].
        uint query = _bound(seed, number - 1 - BUFFER_SIZE, number - 1);

        // Roll to number.
        vm.roll(number);

        // Let system contract have random storage.
        vm.setArbitraryStorage(ExecutionHashes.SYSTEM_CONTRACT);

        // Let block hash of query be zero.
        // This value is returned if the blockhash() optimization is utilized.
        vm.setBlockhash(query, bytes32(0));

        // Read block hash from system contract.
        bytes32 got = ExecutionHashes.get(query);

        // The expected block hash is either the result of blockhash() or the
        // value at storage slot query % BUFFER_SIZE.
        bytes32 want;
        if (query >= number - 1 - 256) {
            want = blockhash(query);
        } else {
            want = vm.load(
                ExecutionHashes.SYSTEM_CONTRACT, bytes32(query % BUFFER_SIZE)
            );
        }
        assertEq(want, got);
    }

    function testFuzz_get_Boundaries(uint number) public {
        vm.assume(number > BUFFER_SIZE - 2);

        // Roll to number.
        vm.roll(number);

        // Revert for number.
        vm.expectRevert(NoExecutionHashFound.selector);
        ExecutionHashes.get(number);

        // Does not revert for number - 1.
        ExecutionHashes.get(number - 1);

        // Does not revert for number - 1 - BUFFER_SIZE.
        ExecutionHashes.get(number - 1 - BUFFER_SIZE);

        // Revert for number - 1 - BUFFER_SIZE - 1.
        vm.expectRevert(NoExecutionHashFound.selector);
        ExecutionHashes.get(number - 1 - BUFFER_SIZE - 1);
    }
}
