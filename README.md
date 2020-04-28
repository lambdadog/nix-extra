# Nix Extra

My personal nix helpers

## `nix-profile`

A trivial-style builder that takes a list of packages and builds a
derivation containing the script `switch-to-profile` which will switch
the current user to a profile containing only those packages.

The basic building block for declarative user-env management without
taking things quite as far as `home-manager`.

Usage:

```nix
{ pkgs ? import <nixpkgs> {} }:

let
  nixProfile = callPackage ./path-to-repository/nix-profile {};
in
  nixProfile [
    # Add packages here
    hello
  ]
```

```
$ nix-build
$ result/bin/switch-to-profile
```