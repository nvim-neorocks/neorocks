#!/bin/sh

# This is an example script on how to run busted tests using Neovim as a lua interpreter locally,
# without neolua or neorocks.

luarocks init
luarocks install busted 2.1.2-3
luarocks config --scope project lua_version 5.1
nvim -c 'lua package.path="lua_modules/share/lua/5.1/?.lua;lua_modules/share/lua/5.1/?/init.lua;"..package.path;package.cpath="lua_modules/lib/lua/5.1/?.so;"..package.cpath;local k,l,_=pcall(require,"luarocks.loader") _=k and l.add_context("busted","2.1.2-3")' -l 'lua_modules/lib/luarocks/rocks-5.1/busted/2.1.2-3/bin/busted' "$@"
