> [!WARNING]
> Deprecated in favor of the official [Dagger flake](https://github.com/dagger/nix).

# Nix flake for Dagger

## Usage

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    dagger.url = "github:sagikazarmark/dagger-flake";
    dagger.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, dagger, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShell = pkgs.mkShell {
          buildInputs = [ dagger.dagger ];
        };
      });
}
```

TODO: add overlay example
TODO: add flake parts example

## Why?

In October 2023 [@shykes](https://github.com/shykes) raised some concerns on [Discord](https://discord.com/channels/707636530424053791/1162145252338049046/1162152750474350793) around how Nix packages Dagger. The particular concern was that Nix (and many other package managers) compiled Dagger from source AND packaged it using the name "dagger" which was not allowed under Dagger's [Trademark policy](https://dagger.io/trademark).

Subsequently, I ([@sagikazarmark](https://github.com/sagikazarmark)) raised an issue in the nixpkgs repository ([#260848](https://github.com/NixOS/nixpkgs/issues/260848)) to discuss the matter with Nix maintainers which (after a brief conversation) resulted in Dagger being removed from nixpkgs.

I started working on this flake to provide a way to install Dagger using Nix, while respecting the Dagger trademark policy.
