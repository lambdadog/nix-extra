{ buildEnv, writeShellScriptBin, writeTextDir }:

{ name ? "user-environment"

, # A list of packages to install
  packages

, # If true, don't allow the user-environment to be modified imperatively
  static ? false
}:

let
  serialize = value:
    let
      type = builtins.typeOf value;
    in
      if type == "string" || type == "bool" || type == "int"
        then builtins.toJSON value
      else if type == "list"
        then builtins.concatStringsSep "" [
          "["
          (builtins.concatStringsSep " " (builtins.map serialize value))
          "]"
        ]
      else if type == "set"
        then builtins.concatStringsSep " " [
          "{"
          (builtins.concatStringsSep " "
            (builtins.map
              (name: builtins.concatStringsSep "" [
                (builtins.toJSON name) # Be safe and quote it
                " = "
                (serialize value.${name})
                ";"
              ]) (builtins.attrNames value)))
          "}"
        ]
      else throw "Couldn't serialize value of type '${type}'";
  
  manifest = writeTextDir "manifest.nix"
    (if !static
     then serialize (map (pkg: with pkg; {
       inherit meta name outPath outputs system type;
       out = {
         inherit outPath;
       };
     }) packages)
     else ''
     abort "user-environment is static and cannot be modified imperatively"
     '');  

  profile = buildEnv {
    inherit name;
    
    paths = packages ++ [ manifest ];
  };
in writeShellScriptBin "install-user-environment" ''
  nix-env --set ${profile}
'';
