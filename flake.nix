{
  description = "Flake for building blog.different-name.com";

  inputs = {
    anemone = {
      url = "github:Speyll/anemone";
      flake = false;
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    systems.url = "github:nix-systems/default";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = import inputs.systems;

      perSystem = { self', pkgs, ...}: let
        theme = inputs.anemone;
        themeName = ((builtins.fromTOML (builtins.readFile "${theme}/theme.toml")).name);
      in {
        packages = {
          different-name-blog = pkgs.stdenv.mkDerivation {
            pname = "different-name-blog";
            version = "2024-08-23";
            src = ./.;
            nativeBuildInputs = with pkgs; [zola];
            configurePhase = ''
              mkdir -p "themes/${themeName}"
              cp -r ${theme}/. "themes/${themeName}"
            '';
            buildPhase = "zola build";
            installPhase = "cp -r public $out";
          };

          default = self'.packages.different-name-blog;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [zola];
          shellHook = ''
            mkdir -p themes
            ln -sn "${theme}" "themes/${themeName}"
          '';
        };
      };
    };
}
