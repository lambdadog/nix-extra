# `nix-extra`

My personal nix helpers

## `user-environment`

A trivial-style builder that takes a list of packages and builds a
derivation containing the script `switch-to-environment` which will
switch the current user to a user environment containing only those
packages.

The basic building block for declarative user-env management without
taking things quite as far as `home-manager`.

Usage:

```nix
{ pkgs ? import <nixpkgs> {} }:

with pkgs; with callPackage (fetchgit {
  url    = "https://github.com/transitracer/nix-extra";
  rev    = ...;
  sha256 = ...;
}) {};

userEnv [
  # Add packages here
  hello
]
```

```sh
$ nix-build
$ result/bin/switch-to-environment
```

## `emacs-with-config`

A wrapper for `emacsWithPackages` that uses the `-Q` and `--load`
flags to load a config without looking at `~/.emacs.d`.

Introduces some jank. Notably, ruins emacs start profiling.

Usage:

```nix
{ pkgs ? import <nixpkgs> {} }:

with pkgs; with callPackage (fetchgit {
  url    = "https://github.com/transitracer/nix-extra";
  rev    = ...;
  sha256 = ...;
}) {};

emacsWithConfig {
  packages = ep: with ep; [ magit ];
  config = ''
    (require 'magit)
  '';
}
```

Instead of a string, `emacsWithConfig` can also take a filepath or a
derivation. If the path or derivation isn't a single file,
`emacsWithConfig` assumes that `init.el` exists in the root of it with
no error checking, so user be warned.

Notes/Tips:

  - To access other files in your configuration directory, you may
    want to call

    ```lisp
    (setq config-home (if load-file-name
                          (file-name-directory load-file-name)
                        default-directory))
    ```

    in your `init.el` to get the root of your config derivation if you
    don't pass it some other way.

  - When passing a path to a nix derivation, the path is copied into
    the nix store before being used, so your config will be read-only.

  - On MacOS, Emacs.app never inherits information from your shell
    env. The `sourceFiles` argument is an optional argument to
    `emacsWithPackages` that allows you to list (bash-compatible)
    files to source so Emacs is able to inherit your shell enviroment.