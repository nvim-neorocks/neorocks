# Nix flake GitHub Actions CI template

A template for setting up GitHub Actions with [Nix flakes](https://nixos.wiki/wiki/Flakes).

![Nix](https://img.shields.io/badge/nix-0175C2?style=for-the-badge&logo=NixOS&logoColor=white)

## Setup

1. Click on [Use this template](https://github.com/MrcJkb/nix-flake-github-ci-template/generate)
to start a repo based on this template. **Do _not_ fork it.**
2. Set up a [Cachix binary cache](https://app.cachix.org/cache) and add the
`CACHIX_AUTH_TOKEN` variable to the repository.
3. Change the `name` fields in [`nix-build.yaml`](./.github/workflows/nix-build.yml).
4. Add your tests to [`mkTest` in the `ci-overlay.nix`](./nix/ci-overlay.nix).

## Contributing

All contributions are welcome!
See [CONTRIBUTING.md](./CONTRIBUTING.md).
