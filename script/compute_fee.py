# Script to compute fee for withdrawals and consolidations system contracts
# given the excess value.
#
# Note that the script is expected to be run via uv to manage dependencies.
#
# Usage:
#   $ uv run script/compute_fee.py $excess
#   > $fee
#
# Example:
#   $ uv run script/compute_fee.py 15
#   > 2
import sys
from eth_abi import encode

# Copied from EIP
def fake_exponential(factor: int, numerator: int, denominator: int) -> int:
    i = 1
    output = 0
    numerator_accum = factor * denominator
    while numerator_accum > 0:
        output += numerator_accum
        numerator_accum = (numerator_accum * numerator) // (denominator * i)
        i += 1
    return output // denominator

# Expect exactly one argument
if len(sys.argv) != 2:
    exit(1)

# Read arg as excess value.
excess = int(sys.argv[1])

# Constants from the contracts. Same for both, consolidations and withdrawals.
FACTOR = 1
DENOMINATOR = 17

# Compute fee.
fee = fake_exponential(FACTOR, excess, DENOMINATOR)

# Note that eth_abi::encode does not work if value > type(uint).max.
# If this is the case, just print zero.
try:
    print("0x" + encode(['uint256'], [fee]).hex())
except Exception as e:
    print("0x" + encode(['uint256'], [int(0)]).hex())
