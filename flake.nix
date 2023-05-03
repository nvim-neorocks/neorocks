{
  description = "Luarocks with Neovim as the Lua interpreter";

  nixConfig = {
    extra-substituters = "https://mrcjkb.cachix.org";
    extra-trusted-public-keys = "mrcjkb.cachix.org-1:KhpstvH5GfsuEFOSyGjSTjng8oDecEds7rbrI96tjA4=";
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    flake-utils.url = "github:numtide/flake-utils";

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly = {
      url = "github:neovim/neovim?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    pre-commit-hooks,
    flake-utils,
    neovim-nightly,
    ...
  }: let
    supportedSystems = [
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
      "x86_64-linux"
    ];
    overlay = import ./nix/overlay.nix {neovim-input = neovim-nightly;};
  in
    flake-utils.lib.eachSystem supportedSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          overlay
        ];
      };

      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = self;
        hooks = {
          cabal2nix.enable = true;
          alejandra.enable = true;
          editorconfig-checker.enable = true;
          markdownlint.enable = true;
          fourmolu.enable = true;
          hpack.enable = true;
          hlint.enable = true;
        };
        settings = {
          alejandra.exclude = ["neolua/default.nix"];
        };
      };

      neoluaShell = pkgs.haskellPackages.shellFor {
        name = "neolua-shell";
        packages = p: with p; [neolua-bin];
        withHoogle = true;
        buildInputs =
          (with pkgs; [
            haskell-language-server
            cabal-install
            zlib
            haskellPackages.neolua-bin
            neorocks
          ])
          ++ (with pre-commit-hooks.packages.${system}; [
            hlint
            hpack
            fourmolu
            cabal2nix
            alejandra
          ]);
        shellHook = ''
          ${self.checks.${system}.pre-commit-check.shellHook}
        '';
      };
    in {
      devShells = {
        default = neoluaShell;
        inherit neoluaShell;
      };

      packages = rec {
        default = neorocks;
        neorocks = pkgs.neorocks;
        neolua-bin = pkgs.haskellPackages.neolua-bin;
      };

      checks = {
        inherit pre-commit-check;
      };
    })
    // {
      overlays = {
        default = overlay;
      };
    };
}
