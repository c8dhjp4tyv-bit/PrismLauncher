# Timeless Launcher Nix packaging

The flake exposes a wrapped package and a minimal package for Linux and macOS.
The repository does not configure a binary cache or trusted signing key; use
your own cache only after reviewing and trusting its operator.

## Flake usage

Add the repository as an input:

```nix
{
  inputs.timeless-launcher.url = "github:c8dhjp4tyv-bit/TimelessLauncher";

  outputs = { nixpkgs, timeless-launcher, ... }:
    {
      nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ pkgs, ... }: {
            environment.systemPackages = [
              timeless-launcher.packages.${pkgs.system}.timeless-launcher
            ];
          })
        ];
      };
    };
}
```

For an ad-hoc install:

```sh
nix run github:c8dhjp4tyv-bit/TimelessLauncher
nix shell github:c8dhjp4tyv-bit/TimelessLauncher
nix profile install github:c8dhjp4tyv-bit/TimelessLauncher
```

The overlay provides the same packages through `pkgs`:

```nix
{
  nixpkgs.overlays = [ timeless-launcher.overlays.default ];
  environment.systemPackages = [ pkgs.timeless-launcher ];
}
```

## Local development

Enter the development shell with:

```sh
nix develop
```

The shell configures a debug CMake/Ninja build and initializes the required
submodules. To build directly:

```sh
nix build .#timeless-launcher
nix build .#timeless-launcher-unwrapped
nix build .#timeless-launcher-debug
```

## Package variants

- `timeless-launcher`: wrapped runtime with the libraries and Java runtimes commonly needed to run Minecraft.
- `timeless-launcher-unwrapped`: minimal package for advanced runtime customization.
- `timeless-launcher-debug`: unstripped debug package for CI and diagnostics.

The wrapped package accepts `additionalLibs`, `additionalPrograms`,
`controllerSupport`, `gamemodeSupport`, `jdks`, `msaClientID` and
`textToSpeechSupport` overrides. Microsoft authentication remains disabled
unless a maintainer supplies a client ID through the build configuration.
