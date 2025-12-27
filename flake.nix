{
  description = "hyperfine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      with import nixpkgs { inherit system; };
      with pkgs;
      let
        version = "1.20.0";
        src = fetchFromGitHub {
          owner = "sharkdp";
          repo = "hyperfine";
          rev = "v${version}";
          hash = "sha256-Ee889Fx2Mi2005SrlcKc7TwG8ZIpTqisfLebXYadvSg=";
        };
        # From https://github.com/NixOS/nixpkgs/blob/59e69648d345d6e8fef86158c555730fa12af9de/pkgs/by-name/hy/hyperfine/package.nix
        hyperfine = rustPlatform.buildRustPackage rec {
          inherit src version;
          pname = "hyperfine";

          cargoHash = "sha256-0e6QDVv//WQtfvrJj6jW1sEz7jFv3VC6UKLvclyytLs=";

          nativeBuildInputs = [ installShellFiles ];

          postInstall = ''
            installManPage doc/hyperfine.1

            installShellCompletion \
              $releaseDir/build/hyperfine-*/out/hyperfine.{bash,fish} \
              --zsh $releaseDir/build/hyperfine-*/out/_hyperfine
          '';
        };
        scripts-python = (
          pkgs.python3.withPackages (
            python-pkgs: with python-pkgs; [
              matplotlib
              numpy
              pyqt6
              scipy
            ]
          )
        );
        scripts = python3Packages.buildPythonPackage rec {
          pname = "hyperfine-scripts";
          inherit src version;

          propagatedBuildInputs = with python3Packages; [
            matplotlib
            numpy
            pyqt6
            scipy
          ];

          doCheck = false;

          buildPhase = ''
            true
          '';

          format = "other";

          installPhase = ''
            mkdir -p $out/bin
            mkdir -p $out/share/hyperfine/scripts

            # Copy the original plot_*.py scripts
            cp ${src}/scripts/*.py $out/share/hyperfine/scripts/

            # For each plot script create a lightweight wrapper in bin/
            for script in $out/share/hyperfine/scripts/*.py; do
              name=$(basename "$script" .py)
              bin_name=$(printf '%s' "$name" | sed 's/_/-/g')
              wrapper="$out/bin/hyperfine-$bin_name"
              cat > "$wrapper" <<EOF
            #!${scripts-python.interpreter}
            import os, sys
            script = os.path.join(os.path.dirname(__file__), "..", "share", "hyperfine", "scripts", "$name.py")
            sys.exit(os.execv(sys.executable, [sys.executable, script] + sys.argv[1:]))
            EOF
              chmod +x "$wrapper"
            done
          '';
        };
      in
      {
        devShells.default = mkShell {
          buildInputs = [
            hyperfine
            scripts
          ];
        };
        packages = {
          inherit hyperfine scripts;
          default = hyperfine;
        };
      }
    );
}
