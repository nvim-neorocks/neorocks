{}: final: prev:
with final.haskell.lib;
with final.lib; let
  haskellPackages = prev.haskellPackages.override (old: {
    overrides = final.lib.composeExtensions (old.overrides or (_: _: {})) (
      self: super: let
        neoluaPkg = buildFromSdist (self.callPackage ../neolua/default.nix {});
        neolua = generateOptparseApplicativeCompletion "neolua" neoluaPkg;
      in {
        inherit neolua;
      }
    );
  });

  mkNeoluaWrapper = nvim:
    final.pkgs.symlinkJoin {
      name = "neolua";
      paths = [nvim haskellPackages.neolua];
    };
in {
  inherit haskellPackages;
  neolua-stable = mkNeoluaWrapper final.pkgs.neovim;
  neolua-nightly = mkNeoluaWrapper final.pkgs.neovim-nightly;
}
