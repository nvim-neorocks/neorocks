# neorocks

`neorocks` is a [nix](https://nixos.org/) derivation
that allows you to run [luarocks](https://luarocks.org/) with [Neovim](https://neovim.io/)
(0.9 and nightly) as the Lua interpreter.

## Why?

So you can use [busted](https://lunarmodules.github.io/busted/) to test your
Neovim plugins with access to the Neovim Lua API.

This was designed for use with the [luarocks-tag-release](https://github.com/nvim-neorocks/luarocks-tag-release)
GitHub action.

## Usage

- See the [`luarocks test`](https://github.com/luarocks/luarocks/wiki/test) documentation.
- An example project can be found in the [`testproject`](./testproject) subdirectory.

### With Nix

```console
nix shell "github:nvim-neorocks/neorocks"
# In the root of your lua project:
luarocks init
# lua interpreters: lua, neolua [neovim 0.9] or neolua-nightly
luarocks config --scope project lua_interpreter neolua
luarocks test
```

### Without Nix

- [ ] TODO: Write documentation on how to use this locally.
