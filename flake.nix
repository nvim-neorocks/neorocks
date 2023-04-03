{
  description = "Nix flake CI template for GitHub Actions"; # TODO: Set description

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
  };

  outputs = {
    self,
    nixpkgs,
    pre-commit-hooks,
    flake-utils,
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
      ci-overlay = import ./nix/ci-overlay.nix {};

      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          ci-overlay
        ];
      };

      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = self;
        hooks = {
          alejandra.enable = true;
          editorconfig-checker.enable = true;
          markdownlint.enable = true;
        };
        settings = {
          markdownlint.config = {
            MD024 = false; # Duplicate heading
          };
        };
      };

      devShell = pkgs.mkShell {
        name = "devShell"; # TODO: Choose a name
        inherit (pre-commit-check) shellHook;
        buildInputs = with pkgs; [
          zlib
        ];
      };
    in {
      devShells = {
        default = devShell;
        inherit devShell;
      };

      # overlays = {
      # };

      # packages = {
      # };

      checks = {
        formatting = pre-commit-check;
        # inherit
        #   (pkgs)
        #   ;
      };
    });
}
