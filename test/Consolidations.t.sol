// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import {console2 as console} from "forge-std/console2.sol";

import {Consolidations} from "../src/Consolidations.sol";

import {Geas} from "../script/Geas.sol";

contract ConsolidationsTest is Test {
    bytes32 constant SLOT_EXCESS = bytes32(0);
    uint constant INHIBITOR = type(uint).max;

    function setUp() public {
        bytes memory code =
            Geas.compile("lib/sys-asm/src/consolidations/main.eas");

        vm.etch(Consolidations.SYSTEM_CONTRACT, code);
    }

    function testFuzz_request(uint seed) public {
        vm.assume(seed < type(uint).max - 2);

        // Create random request payload from seed.
        //
        // Note that payload's size MUST be 96.
        bytes memory payload = bytes.concat(
            keccak256(abi.encodePacked(seed)),
            keccak256(abi.encodePacked(seed + 1)),
            keccak256(abi.encodePacked(seed + 2))
        );

        // Deal enough ETH to cover fee to address(this).
        vm.deal(address(this), type(uint).max);

        // Let system contract have reasonable excess derived from seed.
        uint excess = _bound(seed, 0, 2892);
        vm.store(Consolidations.SYSTEM_CONTRACT, SLOT_EXCESS, bytes32(excess));

        // Request a consolidation.
        //
        // Note that event is emitted iff request got sucessfully added.
        // TODO: Does not work eventhough event is emitted.
        //       Maybe foundry cannot introspect enough due to asm?
        //       Weird... If enabled tests fails with InsufficientFee().
        //vm.expectEmitAnonymous();
        Consolidations.request(payload);

        // Verify requests got added via checking that fee got paid.
        assertTrue(address(this).balance < type(uint).max);
    }

    function testFuzz_getExcess(uint excess) public {
        // Store given excess in system contract.
        //
        // Note to ensure excess is not inhibitor, ie system contract is
        // activated.
        vm.assume(excess != INHIBITOR);
        vm.store(Consolidations.SYSTEM_CONTRACT, SLOT_EXCESS, bytes32(excess));

        assertEq(Consolidations.getExcess(), excess);
    }

    function testFuzzDifferential_computeFee(uint excess) public {
        // Note that python spec and EVM implementation of the fake_expo
        // function differs starting at an excess > 2892.
        vm.assume(excess <= 2892);

        // Store excess in system contract.
        vm.store(Consolidations.SYSTEM_CONTRACT, SLOT_EXCESS, bytes32(excess));

        uint got = Consolidations.computeFee();

        // Use python spec as source of truth.
        string[] memory inputs = new string[](4);
        inputs[0] = "uv";
        inputs[1] = "run";
        inputs[2] = "script/compute_fee.py";
        inputs[3] = vm.toString(excess);
        uint want = abi.decode(vm.ffi(inputs), (uint));

        assertEq(want, got);
    }
}
