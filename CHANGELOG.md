<!-- markdownlint-disable -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2024-06-21

### BREAKING CHANGE

- Drop `neolua` in favour of [`nlua`](https://github.com/mfussenegger/nlua).
  This removes the `neolua` and `neorocks` flake outputs, and the ones that
  depend on them.
  Instead, this flake now provides a `busted-nlua` flake output that
  has `busted` preconfigured to use `nlua`.

## [1.1.0] - 2023-09-01

### Added

- `neorocksTest` function.

## [1.0.0] - 2023-06-04

### Added

- Initial release.
