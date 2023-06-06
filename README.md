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
      Run <a href="https://lunarmodules.github.io/busted/">busted</a> tests with <a href="https://neovim.io/">Neovim</a>.
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
[![Hackage][hackage-shield]][hackage-url]

## What?

- `neorocks` is a [nix](https://nixos.org/) derivation
  that allows you to run [luarocks](https://luarocks.org/) with [Neovim](https://neovim.io/)
  (version 0.9 and nightly) as the Lua interpreter.
- `neolua` is a CLI wrapper around Neovim,
  which maps Lua's CLI arguments to Neovim's CLI arguments.
  It is used by `neorocks`.

## Why?

So you can use [busted](https://lunarmodules.github.io/busted/) to test your
Neovim plugins with access to the Neovim Lua API.

This was designed for use with the [luarocks-tag-release](https://github.com/nvim-neorocks/luarocks-tag-release)
GitHub action.

## How?

- See the [`luarocks test`](https://github.com/luarocks/luarocks/wiki/test) documentation.
- An example project can be found in the [`testproject`](./testproject) subdirectory.
- Neovim plugins should have a [`rockspec`](./testproject/testproject-scm-1.rockspec)
  and a [`.busted`](./testproject/.busted) file in the project root.

### With Nix

```console
nix shell "github:nvim-neorocks/neorocks"
# In the root of your lua project:
luarocks init
# lua interpreters: lua, neolua [neovim 0.9] or neolua-nightly
luarocks config --scope project lua_interpreter neolua
luarocks test
```

### Without Nix (using `neolua`)

- Install `lua 5.1` and `luarocks` with your distribution's package manager.
- `neolua` is [available on Hackage](https://hackage.haskell.org/package/neolua-1.0.0).
  You can install it using the `cabal-install` package from your
  distributions package manager (if using Linux or Mac).
- Make sure `neolua` is installed or symlinked into the same directory as `luarocks`
  (e.g. `/usr/bin`).

```console
# In the root of your lua project:
luarocks init
# lua interpreters: lua, neolua [neovim 0.9] or neolua-nightly
luarocks config --scope project lua_version 5.1
# The path to luajit may vary depending on your system.
luarocks config --scope project variables.LUA_INCDIR /usr/include/luajit-2.1
luarocks config --scope project lua_interpreter neolua
luarocks test
```

### Without `neolua`

To run tests locally, without `neorocks` or `neolua`...

- Install `lua 5.1` and `luarocks` with your distribution's package manager.
- Add `luarocks`, `lua_modules` and `.luarocks` to your project's `.gitignore`.
- Add the following shell script to your project:

<!-- markdownlint-disable -->
```sh
#!/bin/sh
BUSTED_VERSION="2.1.2-3"
luarocks init
luarocks install busted "$BUSTED_VERSION"
luarocks config --scope project lua_version 5.1
nvim --noplugin \
  -c "lua package.path='lua_modules/share/lua/5.1/?.lua;lua_modules/share/lua/5.1/?/init.lua;'..package.path;package.cpath='lua_modules/lib/lua/5.1/?.so;'..package.cpath;local k,l,_=pcall(require,'luarocks.loader') _=k and l.add_context('busted','$BUSTED_VERSION')" \
  -l "lua_modules/lib/luarocks/rocks-5.1/busted/$BUSTED_VERSION/bin/busted" "$@"
```
<!-- markdownlint-restore -->

- If your project depends on other luarocks packages,
  add them to your project's rockspec.
- See also the example project in the [`testproject`](./testproject) subdirectory.

> **Note**
>
> If your tests are not in a `spec` directory,
> pass the name of the test directory to the script.
> e.g., `./run-tests.sh tests`

### With GitHub Actions

- We recommend using the [luarocks-tag-release](https://github.com/nvim-neorocks/luarocks-tag-release)
  action, which uses `neorocks` to run tests and publishes your package
  to luarocks.
- Alternatively, you can see the `tests` job of
  [this project's CI](./.github/workflows/nix-build.yml)
  for an example on how to use `neorocks` with GitHub actions manually.

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
[hackage-shield]: https://img.shields.io/hackage/v/neolua.svg?style=for-the-badge
[hackage-url]: https://hackage.haskell.org/package/neolua
