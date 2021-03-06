{ pkgs ? import <nixpkgs> {} }:

let
  myPkgs = import ./pkgs {
    inherit pkgs;
  };
in {
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;
  overlay = import ./overlay.nix;
  pkgs = myPkgs;
} // myPkgs
