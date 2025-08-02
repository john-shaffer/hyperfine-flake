{
  description = "hyperfine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      with import nixpkgs { inherit system; };
      with pkgs;
      let
        version = "1.19.0";
        src = fetchFromGitHub {
          owner = "sharkdp";
          repo = "hyperfine";
          rev = "v${version}";
          hash = "sha256-c8yK9U8UWRWUSGGGrAds6zAqxAiBLWq/RcZ6pvYNpgk=";
        };
        # From https://github.com/NixOS/nixpkgs/blob/59e69648d345d6e8fef86158c555730fa12af9de/pkgs/by-name/hy/hyperfine/package.nix
        hyperfine = rustPlatform.buildRustPackage rec {
          inherit src version;
          pname = "hyperfine";

          useFetchCargoVendor = true;
          cargoHash = "sha256-eZpGqkowp/R//RqLRk3AIbTpW3i9e+lOWpfdli7S4uE=";

          nativeBuildInputs = [ installShellFiles ];

          postInstall = ''
            installManPage doc/hyperfine.1

            installShellCompletion \
              $releaseDir/build/hyperfine-*/out/hyperfine.{bash,fish} \
              --zsh $releaseDir/build/hyperfine-*/out/_hyperfine
          '';
        };
      in {
        devShells.default = mkShell { buildInputs = [ hyperfine ]; };
        lib = import ./src/lib.nix;
        packages = {
          inherit hyperfine;
          default = hyperfine;
        };
      });
}
