{
  description = "Timeless Launcher, an independently branded launcher for managing multiple Minecraft installations";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";

    libnbtplusplus = {
      url = "github:PrismLauncher/libnbtplusplus";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      libnbtplusplus,
    }:

    let
      inherit (nixpkgs) lib;

      # While we only officially support aarch and x86_64 on Linux and MacOS,
      # we expose a reasonable amount of other systems for users who want to
      # build for most exotic platforms
      systems = lib.systems.flakeExposed;

      forAllSystems = lib.genAttrs systems;
      nixpkgsFor = forAllSystems (system: nixpkgs.legacyPackages.${system});
    in

    {
      checks = forAllSystems (
        system:

        let
          pkgs = nixpkgsFor.${system};
          llvm = pkgs.llvmPackages_22;
        in

        {
          formatting =
            pkgs.runCommand "check-formatting"
              {
                nativeBuildInputs = with pkgs; [
                  deadnix
                  llvm.clang-tools
                  markdownlint-cli
                  nixfmt-rfc-style
                  statix
                ];
              }
              ''
                cd ${self}

                echo "Running clang-format...."
                clang-format --dry-run --style='file' --Werror */**.{c,cc,cpp,h,hh,hpp}

                echo "Running deadnix..."
                deadnix --fail

                echo "Running markdownlint..."
                markdownlint --dot .

                echo "Running nixfmt..."
                find -type f -name '*.nix' -exec nixfmt --check {} +

                echo "Running statix"
                statix check .

                touch $out
              '';
        }
      );

      devShells = forAllSystems (
        system:

        let
          pkgs = nixpkgsFor.${system};
          llvm = pkgs.llvmPackages_22;
          python = pkgs.python3;
          mkShell = pkgs.mkShell.override { inherit (llvm) stdenv; };

          packages' = self.packages.${system};

          welcomeMessage = ''
            Welcome to the Timeless Launcher repository!

            We just set some things up for you. To get building, you can run:

            ```
            $ cd "$cmakeBuildDir"
            $ ninjaBuildPhase
            $ ninjaInstallPhase
            ```

            Please use the issue tracker for project questions and support:
              - https://github.com/c8dhjp4tyv-bit/PrismLauncher/issues

            And thanks for helping out :)
          '';

          # Re-use our package wrapper to wrap our development environment
          qt-wrapper-env = packages'.timeless-launcher.overrideAttrs (old: {
            name = "qt-wrapper-env";

            # Required to use script-based makeWrapper below
            strictDeps = true;

            # We don't need/want the unwrapped Timeless Launcher package
            paths = [ ];

            nativeBuildInputs = old.nativeBuildInputs or [ ] ++ [
              # Ensure the wrapper is script based so it can be sourced
              pkgs.makeWrapper
            ];

            # Inspired by https://discourse.nixos.org/t/python-qt-woes/11808/10
            buildCommand = ''
              makeQtWrapper ${lib.getExe pkgs.runtimeShellPackage} "$out"
              sed -i '/^exec/d' "$out"
            '';
          });
        in

        {
          default = mkShell {
            name = "timeless-launcher";

            inputsFrom = [ packages'.timeless-launcher-unwrapped ];

            packages = [
              pkgs.ccache
              llvm.clang-tools
              python # NOTE(@getchoo): Required for run-clang-tidy, etc.

              (pkgs.stdenvNoCC.mkDerivation {
                pname = "clang-tidy-diff";
                inherit (llvm.clang) version;

                nativeBuildInputs = [
                  pkgs.installShellFiles
                  python.pkgs.wrapPython
                ];

                dontUnpack = true;
                dontConfigure = true;
                dontBuild = true;

                postInstall = "installBin ${llvm.libclang.python}/share/clang/clang-tidy-diff.py";
                postFixup = "wrapPythonPrograms";
              })
            ];

            cmakeBuildType = "Debug";
            cmakeFlags = [ "-GNinja" ] ++ packages'.timeless-launcher-unwrapped.cmakeFlags;
            dontFixCmake = true;

            shellHook = ''
              echo "Sourcing ${qt-wrapper-env}"
              source ${qt-wrapper-env}

              git submodule update --init --force

              if [ ! -f compile_commands.json ]; then
                cmakeConfigurePhase
                cd ..
                ln -s "$cmakeBuildDir"/compile_commands.json compile_commands.json
              fi

              echo ${lib.escapeShellArg welcomeMessage}
            '';
          };
        }
      );

      formatter = forAllSystems (system: nixpkgsFor.${system}.nixfmt-rfc-style);

      overlays.default =
        final: prev:

        let
          llvm = final.llvmPackages_22 or prev.llvmPackages_22;
        in

        {
          timeless-launcher-unwrapped = prev.callPackage ./nix/unwrapped.nix {
            inherit (llvm) stdenv;
            inherit
              libnbtplusplus
              self
              ;
          };

          timeless-launcher = final.callPackage ./nix/wrapper.nix { };
        };

      packages = forAllSystems (
        system:

        let
          pkgs = nixpkgsFor.${system};

          # Build a scope from our overlay
          timelessPackages = lib.makeScope pkgs.newScope (final: self.overlays.default final pkgs);

          # Grab our packages from it and set the default
          packages = {
            inherit (timelessPackages) timeless-launcher-unwrapped timeless-launcher;
            default = timelessPackages.timeless-launcher;
          };
        in

        # Only output them if they're available on the current system
        lib.filterAttrs (_: lib.meta.availableOn pkgs.stdenv.hostPlatform) packages
      );

      # We put these under legacyPackages as they are meant for CI, not end user consumption
      legacyPackages = forAllSystems (
        system:

        let
          packages' = self.packages.${system};
          legacyPackages' = self.legacyPackages.${system};
        in

        {
          timeless-launcher-debug = packages'.timeless-launcher.override {
            timeless-launcher-unwrapped = legacyPackages'.timeless-launcher-unwrapped-debug;
          };

          timeless-launcher-unwrapped-debug = packages'.timeless-launcher-unwrapped.overrideAttrs {
            cmakeBuildType = "Debug";
            dontStrip = true;
          };
        }
      );
    };
}
