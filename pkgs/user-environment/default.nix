{ buildEnv, writeShellScriptBin }:

packages:

let
  profile = buildEnv {
    name = "user-environment";
    
    paths = packages;
  };

  shellCommand = ''
  nix-shell -p ${profile}
  '';

  testCommand = ''
  nix-env --set ${profile}
  '';

  switchCommand = ''
  echo "Switching to read-only profile"
  nix-env --switch-profile ${profile}
  '';

  resetCommand = ''
  if [ -d "/nix/var/nix/profiles/per-user/$USER/profile/" ]; then
    echo "Resetting profile to /nix/var/nix/profiles/per-user/$USER/profile/"
    nix-env --switch-profile "/nix/var/nix/profiles/per-user/$USER/profile/"
  else
    echo "Couldn't find a per-user profile for $USER"
    echo "Resetting profile to /nix/var/nix/profiles/default/"
    nix-env --switch-profile "/nix/var/nix/profiles/default/"
  fi
  '';

  commandHelp = ''
  echo "$0 [shell|test|switch|reset]"
  '';

in writeShellScriptBin "switch-to-environment" ''
case $1 in

"shell")
${shellCommand}
;;

"test")
${testCommand}
;;

"switch")
${switchCommand}
;;

"reset")
${resetCommand}
;;

*)
${commandHelp}
;;

esac
''