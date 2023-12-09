{neovim-input}: final: prev:
with prev.haskell.lib;
with prev.lib; let
  haskellPackages = prev.haskellPackages.override (old: {
    overrides = prev.lib.composeExtensions (old.overrides or (_: _: {})) (
      self: super: let
        neoluaPkg = buildFromSdist (
          overrideCabal (super.callPackage ../neolua/default.nix {})
          (old: {
            configureFlags =
              (old.configureFlags or [])
              ++ [
                "--ghc-options=-O2"
                "--ghc-options=-j"
                "--ghc-options=+RTS"
                "--ghc-options=-A256m"
                "--ghc-options=-n4m"
                "--ghc-options=-RTS"
                "--ghc-options=-Wall"
                "--ghc-options=-Werror"
                "--ghc-options=-Wincomplete-uni-patterns"
                "--ghc-options=-Wincomplete-record-updates"
                "--ghc-options=-Wpartial-fields"
                "--ghc-options=-Widentities"
                "--ghc-options=-Wredundant-constraints"
                "--ghc-options=-Wcpp-undef"
                "--ghc-options=-Wunused-packages"
                "--ghc-options=-Wno-deprecations"
              ];
          })
        );
        neolua-bin = prev.haskellPackages.generateOptparseApplicativeCompletions ["neolua"] neoluaPkg;
      in {
        inherit neolua-bin;
      }
    );
  });

  neovim-nightly = neovim-input.packages.${prev.system}.neovim;

  mkNeoluaWrapper = name: neovim:
    prev.pkgs.writeShellApplication {
      inherit name;
      checkPhase = "";
      runtimeInputs = [
        haskellPackages.neolua-bin
        neovim
      ];
      text = ''
        neolua "$@";
      '';
    };

  neolua-stable-wrapper = mkNeoluaWrapper "neolua" prev.pkgs.neovim-unwrapped;

  neolua-nightly-wrapper = mkNeoluaWrapper "neolua-nightly" neovim-nightly;

  lua5_1 =
    (prev.pkgs.lua5_1.overrideAttrs (old: {
      postInstall = ''
        ${old.postInstall}
        ln -s ${neolua-stable-wrapper}/bin/neolua $out/bin/neolua
        ln -s ${neolua-nightly-wrapper}/bin/neolua-nightly $out/bin/neolua-nightly
      '';
    }))
    .override {
      self = lua5_1;
    };

  mkNeorocks = neolua-pkgs:
    prev.pkgs.symlinkJoin {
      name = "neorocks";
      paths =
        [
          final.lua5_1
          final.lua51Packages.luarocks
        ]
        ++ neolua-pkgs;
    };

  neorocks = mkNeorocks [
    neolua-stable-wrapper
    neolua-nightly-wrapper
  ];

  neorocksTest = {
    src,
    name,
    pname ? name, # The plugin/luarocks package name
    neovim ? neovim-nightly,
    version ? "scm-1",
    luaPackages ? _: [], # e.g. p: with p; [plenary.nvim]
    extraPackages ? [], # Extra dependencies
    ...
  } @ attrs: let
    # This allows us to pass in extra attrs to buildLuarocksPackage
    rest = builtins.removeAttrs attrs [
      "src"
      "name"
      "pname"
      "neovim"
      "version"
      "luaPackages"
      "extraPackages"
    ];
    neolua-wrapper = mkNeoluaWrapper "neolua" neovim;

    lua5_1 = prev.pkgs.lua5_1;

    busted = lua5_1.pkgs.busted.overrideAttrs (oa: {
      postInstall = ''
        ${oa.postInstall}
        substituteInPlace ''$out/bin/busted \
          --replace "${lua5_1}/bin/lua" "${neolua-wrapper}/bin/neolua"
      '';
    });
  in (lua5_1.pkgs.buildLuarocksPackage (rest
    // {
      inherit
        src
        version
        pname
        ;
      namePrefix =
        if name == pname
        then ""
        else "${name}-";
      propagatedBuildInputs =
        [
          busted
        ]
        ++ luaPackages lua5_1.pkgs;
      doCheck = true;
      nativeCheckInputs = extraPackages;
    }));
in {
  inherit
    haskellPackages
    neorocks
    neorocksTest
    neovim-nightly
    neolua-stable-wrapper
    neolua-nightly-wrapper
    ;
  lua51Packages = lua5_1.pkgs;
}
