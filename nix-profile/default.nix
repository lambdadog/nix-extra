{ buildEnv, writeShellScriptBin }:

packages:

let
  profile = buildEnv {
    name = "user-environment";
    
    paths = packages;
  };
in writeShellScriptBin "switch-to-profile" ''
nix-env --set ${profile}
''