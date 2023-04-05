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

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    pre-commit-hooks,
    flake-utils,
    neovim-nightly-overlay,
    ...
  }: let
    supportedSystems = [
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  in
    flake-utils.lib.eachSystem supportedSystems (system: let
      overlay = import ./nix/overlay.nix {};

      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          overlay
          neovim-nightly-overlay.overlay
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
        packages = p: with p; [neolua];
        withHoogle = true;
        buildInputs =
          (with pkgs; [
            haskell-language-server
            cabal-install
            zlib
          ])
          ++ (with pre-commit-hooks.packages.${system}; [
            hlint
            hpack
            nixpkgs-fmt
            fourmolu
            cabal2nix
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

      # overlays = {
      # };

      # packages = {
      # };

      checks = {
        inherit pre-commit-check;
      };
    });
}
