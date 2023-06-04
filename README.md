# neorocks-nix

`neorocks-nix` is a **WIP** [Nix](https://nixos.org/) derivation
that allows you to run [luarocks](https://luarocks.org/) with [Neovim](https://neovim.io/)
(0.9 and nightly) as the Lua interpreter.

## Why?

So you can use [busted](https://lunarmodules.github.io/busted/) to test your
Neovim plugin with access to the Neovim Lua API.

## Usage

This is intended to be used with the [luarocks-tag-release](https://github.com/nvim-neorocks/luarocks-tag-release)
GitHub action.

- See [this project's CI](https://github.com/mrcjkb/neorocks-nix/blob/eb3e83501c6375553912aadc37378a004553faa6/.github/workflows/nix-build.yml#L46)
  for a usage example.

- [ ] TODO: Write documentation on how to use this locally.
