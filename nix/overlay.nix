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

  luajit-override =
    (prev.pkgs.luajit.overrideAttrs (old: {
      postInstall = ''
        ${old.postInstall}
        ln -s ${neolua-stable-wrapper}/bin/neolua $out/bin/neolua
        ln -s ${neolua-nightly-wrapper}/bin/neolua-nightly $out/bin/neolua-nightly
      '';
    }))
    .override {
      self = luajit-override;
    };

  neorocks = prev.pkgs.symlinkJoin {
    name = "neorocks";
    paths = [
      luajit-override
      luajit-override.pkgs.luarocks
      neolua-stable-wrapper
      neolua-nightly-wrapper
    ];
  };
in {
  inherit
    haskellPackages
    neorocks
    ;
}
