{neovim-input}: final: prev:
with final.haskell.lib;
with final.lib; let
  haskellPackages = prev.haskellPackages.override (old: {
    overrides = final.lib.composeExtensions (old.overrides or (_: _: {})) (
      self: super: let
        neoluaPkg = buildFromSdist (
          overrideCabal (self.callPackage ../neolua/default.nix {})
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
        neolua-bin = final.haskellPackages.generateOptparseApplicativeCompletions ["neolua"] neoluaPkg;
      in {
        inherit neolua-bin;
      }
    );
  });

  neovim-nightly = neovim-input.packages.${prev.system}.neovim;

  mkNeoluaWrapper = neovim:
    final.pkgs.writeShellApplication {
      name = "neolua";
      checkPhase = "";
      runtimeInputs = [
        haskellPackages.neolua-bin
        neovim
      ];
      text = ''
        neolua "$@";
      '';
    };

  neolua-stable-wrapper = mkNeoluaWrapper final.pkgs.neovim-unwrapped;

  neolua-nightly-wrapper = mkNeoluaWrapper neovim-nightly;

  luajit = prev.pkgs.luajit.overrideDerivation (old: {
    postPatch = ''
      ${old.postPatch}
      mkdir -p $out/bin
      ln -s ${neolua-stable-wrapper}/bin/neolua $out/bin/neolua
      ln -s ${neolua-nightly-wrapper}/bin/neolua $out/bin/neolua-nightly
    '';
  });

  neorocks = prev.pkgs.luajitPackages.luarocks.overrideDerivation (old: {
    nativeBuildInputs = with final; [pkgs.makeWrapper pkgs.installShellFiles luajit pkgs.unzip];
  });
in {
  inherit
    haskellPackages
    neorocks
    ;
}
