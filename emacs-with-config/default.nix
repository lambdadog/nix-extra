{ emacsWithPackages, makeWrapper, writeText, runCommand, lib }:

# emacsWithConfig has leaves you with a double-wrapped emacs, but
# there's not much to be done about that.

# To get the directory of the init file being loaded (for adding other
# config files to load path, etc.), run `(file-name-directory
# load-file-name)`

packagesFun: config:

let
  emacs = emacsWithPackages packagesFun;
  configFile =
    if builtins.isPath config || lib.attrsets.isDerivation config
      then if builtins.pathIsDirectory "${config}"
      	   # FIXME: Check if this file exists
           then "${config}/init.el"
	   else config
    else if builtins.isString config
      then writeText "init.el" config
    else builtins.throw ("config cannot be of type " + builtins.typeOf config);
in runCommand "emacs-with-config" {
  nativeBuildInputs = [ makeWrapper emacs ];
} ''
mkdir -p "$out/bin"

# Wrap emacs to have it ignore .emacs.d and load our elisp file
cp ${emacs}/bin/* $out/bin/
for prog in ${emacs}/bin/{emacs,emacs-*}; do
  local progname=$(basename "$prog")
  rm -f "$out/bin/$progname"
  makeWrapper "$prog" "$out/bin/$progname" \
    --add-flags "-Q --load ${configFile}"
done

# Wrap the MacOS Application, if it exists
if [ -d "${emacs}/Applications/Emacs.app" ]; then
  mkdir -p "$out/Applications/Emacs.app/Contents/MacOS"
  cp -r ${emacs}/Applications/Emacs.app/Contents/Info.plist \
        ${emacs}/Applications/Emacs.app/Contents/PkgInfo \
        ${emacs}/Applications/Emacs.app/Contents/Resources \
        $out/Applications/Emacs.app/Contents
  makeWrapper "${emacs}/Applications/Emacs.app/Contents/MacOS/Emacs" \
              "$out/Applications/Emacs.app/Contents/MacOS/Emacs" \
    --add-flags "-Q --load ${configFile}"
fi

mkdir -p $out/share
# Link icons and desktop files into place
for dir in applications icons info man; do
  ln -s $emacs/share/$dir $out/share/$dir
done
''