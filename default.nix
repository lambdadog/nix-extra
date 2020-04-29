{ pkgs ? import <nixpkgs> {} }:

{
  userEnv         = pkgs.callPackage ./user-environment  {};
  emacsWithConfig = pkgs.callPackage ./emacs-with-config {};
}