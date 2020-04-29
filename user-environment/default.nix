{ buildEnv, writeShellScriptBin }:

packages:

let
  profile = buildEnv {
    name = "user-environment";
    
    paths = packages;
  };
in writeShellScriptBin "switch-to-environment" ''
nix-env --set ${profile}
''