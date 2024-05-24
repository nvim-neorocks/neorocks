{
  description = "Luarocks with Neovim as the Lua interpreter";

  nixConfig = {
    extra-substituters = "https://neorocks.cachix.org";
    extra-trusted-public-keys = "neorocks.cachix.org-1:WqMESxmVTOJX7qoBC54TwrMMoVI1xAM+7yFin8NRfwk=";
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

    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
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
          alejandra = {
            enable = true;
            excludes = [
              "neolua/default.nix"
            ];
          };
          editorconfig-checker.enable = true;
          markdownlint.enable = true;
          fourmolu.enable = true;
          hpack.enable = true;
          hlint.enable = true;
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
            markdownlint-cli
          ]);
        RT_DIR = pkgs.lib.makeLibraryPath [pkgs.glibc];
        shellHook = ''
          ${self.checks.${system}.pre-commit-check.shellHook}
        '';
      };

      neorocksShell = pkgs.mkShell {
        name = "neorocks-shell";
        buildInputs = with pkgs; [
          neorocks
          neolua-stable-wrapper
          neolua-nightly-wrapper
        ];
      };
    in {
      devShells = {
        default = neoluaShell;
        inherit neoluaShell neorocksShell;
      };

      packages = rec {
        default = neorocks;
        neolua-bin = pkgs.haskellPackages.neolua-bin;
        inherit
          (pkgs)
          neorocks
          neovim-nightly
          neolua-stable-wrapper
          neolua-nightly-wrapper
          busted-stable
          busted-nightly
          ;
      };

      checks = {
        inherit pre-commit-check;
        neorocks-test = pkgs.neorocksTest {
          src = ./testproject;
          name = "neorocks-test";
          pname = "testproject";
          neovim = pkgs.neovim-nightly;
          luaPackages = ps:
            with ps; [
              plenary-nvim
            ];
        };
      };
    })
    // {
      overlays = {
        default = overlay;
      };
    };
}
