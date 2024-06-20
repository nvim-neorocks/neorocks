<!-- markdownlint-disable -->
<br />
<div align="center">
  <a href="https://github.com/nvim-neorocks/neorocks">
    <img src="https://avatars.githubusercontent.com/u/124081866?s=400&u=0da379a468d46456477a1f68048b020cf7a99f34&v=4" alt="neorocks">
  </a>
  <p align="center">
    <a href="https://github.com/nvim-neorocks/neorocks/issues">Report Bug</a>
  </p>
  <p>
    <strong>
      neorocks
      <br />
      Run <a href="https://lunarmodules.github.io/busted/">busted</a> tests with <a href="https://neovim.io/">Neovim in your Nix CI</a>.
    </strong>
  </p>
  <h2>🌒</h>
</div>
<!-- markdownlint-restore -->

[![Neovim][neovim-shield]][neovim-url]
[![Lua][lua-shield]][lua-url]
[![Nix][nix-shield]][nix-url]

[![GPL2 License][license-shield]][license-url]
[![Issues][issues-shield]][issues-url]
[![Build Status][ci-shield]][ci-url]

## What?

- `neorocksTest` is a [nix](https://nixos.org/) function
  that allows you to run [`luarocks test`](https://github.com/luarocks/luarocks/wiki/test)
  with [Neovim](https://neovim.io/) as the Lua interpreter.
- This project's README provides tutorials for using [`busted`](https://lunarmodules.github.io/busted/)
  to test Neovim plugins (with and without Nix).

## Why?

So you can use [`busted`](https://lunarmodules.github.io/busted/) to test your
Neovim plugins with access to the Neovim Lua API.

## How?

- See the [`luarocks test`](https://github.com/luarocks/luarocks/wiki/test) documentation.
- An example project can be found in the [`testproject`](./testproject) subdirectory.
- Neovim plugins should have a [`rockspec`](./testproject/testproject-scm-1.rockspec)
  and a [`.busted`](./testproject/.busted) file in the project root.

### In a Nix flake

This project provides a Nix overlay with a `neorocksTest` function.
Here is an example of how to use it in a Nix flake:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    neorocks.url = "github:nvim-neorocks/neorocks";
  };
  outputs = {
    self,
    nixpkgs,
    neorocks,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        neorocks.overlays.default
      ];
    };
  in {
    # ...
    checks.${system} = {
      neorocks-test = pkgs.neorocksTest {
        src = self; # Project containing the rockspec and .busted files.
        # Plugin name. If running multiple tests,
        # you can use pname for the plugin name instead
        name = "my-plugin.nvim"
        version = "scm-1"; # Optional, defaults to "scm-1";
        neovim = pkgs.neovim-nightly; # Optional, defaults to neovim-nightly.
        luaPackages = ps: # Optional
          with ps; [
            # LuaRocks dependencies must be added here.
            plenary-nvim
          ];
        extraPackages = []; # Optional. External test runtime dependencies.
      };
    };
  };
}
```

### In a Nix shell

```bash
nix shell "github:nvim-neorocks/neorocks"
busted
```

### Without Nix (using `nlua`)

See: [mfussenegger/nlua](https://github.com/mfussenegger/nlua)

### Without `nlua`

To run `busted` tests locally, without `neorocks` or `neolua`...

- Install `lua 5.1` and `luarocks` with your distribution's package manager.
- Add `luarocks`, `lua_modules` and `.luarocks` to your project's `.gitignore`.
- Add the following shell script to your project:

<!-- markdownlint-disable -->
```sh
#!/bin/sh
export BUSTED_VERSION="2.1.2-3"
luarocks init
luarocks install busted "$BUSTED_VERSION"
luarocks config --scope project lua_version 5.1
nvim -u NONE \
  -c "lua package.path='lua_modules/share/lua/5.1/?.lua;lua_modules/share/lua/5.1/?/init.lua;'..package.path;package.cpath='lua_modules/lib/lua/5.1/?.so;'..package.cpath;local k,l,_=pcall(require,'luarocks.loader') _=k and l.add_context('busted','$BUSTED_VERSION')" \
  -l "lua_modules/lib/luarocks/rocks-5.1/busted/$BUSTED_VERSION/bin/busted" "$@"
```
<!-- markdownlint-restore -->

- If your project depends on other luarocks packages,
  add them to the `dependencies` and `test_dependencies` in your project's rockspec.
- See also the example project in the [`testproject`](./testproject) subdirectory.

> **Note**
>
> If your tests are not in a `spec` directory,
> pass the name of the test directory to the script.
> e.g., `./run-tests.sh tests`

### With GitHub Actions

- We recommend using the [nvim-busted-action](https://github.com/nvim-neorocks/nvim-busted-action)
  action, which uses `nlua` to run tests,
  or to use the `neorocksTest` helper in a nix-based CI.
- Alternatively, you can see the `tests` job of
  [this project's CI](./.github/workflows/nix-build.yml)
  for an example on how to use `neorocksTest` with GitHub actions manually.

<!-- MARKDOWN LNIKS & IMAGES -->
[neovim-shield]: https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white
[neovim-url]: https://neovim.io/
[lua-shield]: https://img.shields.io/badge/lua-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=white
[lua-url]: https://www.lua.org/
[nix-shield]: https://img.shields.io/badge/nix-0175C2?style=for-the-badge&logo=NixOS&logoColor=white
[nix-url]: https://nixos.org/
[issues-shield]: https://img.shields.io/github/issues/nvim-neorocks/neorocks.svg?style=for-the-badge
[issues-url]: https://github.com/nvim-neorocks/neorocks/issues
[license-shield]: https://img.shields.io/github/license/nvim-neorocks/neorocks.svg?style=for-the-badge
[license-url]: https://github.com/nvim-neorocks/neorocks/blob/master/LICENSE
[ci-shield]: https://img.shields.io/github/actions/workflow/status/nvim-neorocks/neorocks/nix-build.yml?style=for-the-badge
[ci-url]: https://github.com/nvim-neorocks/neorocks/actions/workflows/nix-build.yml
