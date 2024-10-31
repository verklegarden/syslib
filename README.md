<div align="center">

<h1>syslib</h1>

<a href="">[![Tests][tests-shield]][tests-shield-url]</a>
<a href="">![Apache2/MIT licensed][license-shield]</a>

</div>

Solidity libraries to interact with Ethereum system contracts.

## Libraries

```ml
src
├─ BeaconRoots - "Library for the EIP-4788 beacon roots system contract"
├─ ExecutionHashes - "Library for the EIP-2935 execution hashes system contract"
├─ Withdrawals - "Library for the EIP-7002 withdrawals system contract"
└─ Consolidations - "Library for the EIP-7251 consolidations system contract"
```

## Installation

Install with [Foundry](https://getfoundry.sh/):

```bash
$ forge install verklegarden/syslib
```

## Contributing

The project uses the Foundry toolchain. You can find installation instructions [here](https://getfoundry.sh/).

Setup:

```bash
$ git clone https://github.com/verklegarden/syslib
$ cd syslib/
$ forge install
```

## Safety

This is **experimental software** and is provided on an "as is" and "as available" basis.

We **do not give any warranties** and **will not be liable** for any loss incurred through any use of this codebase.

## License

Licensed under either of <a href="LICENSE-APACHE">Apache License, Version 2.0</a> or <a href="LICENSE-MIT">MIT license</a> at your option.

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion by you, as defined in the Apache-2.0 license, shall be dual licensed as above, without any additional terms or conditions.

<!--- Shields -->
[tests-shield]: https://github.com/verklegarden/syslib/actions/workflows/ci.yml/badge.svg
[tests-shield-url]: https://github.com/verklegarden/syslib/actions/workflows/ci.yml
[license-shield]: https://img.shields.io/badge/license-Apache2.0/MIT-blue.svg
