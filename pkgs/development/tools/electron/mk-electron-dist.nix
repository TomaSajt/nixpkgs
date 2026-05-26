{
  runCommand,
  strip-nondeterminism,
  zip,
  stdenv,
}:

electron:
let
  inherit (stdenv.hostPlatform.node) platform arch;

  archivePrefix = "electron-v${electron.version}-${platform}-${arch}";
  zipName = "${archivePrefix}.zip";

  zipDir =
    runCommand "${electron.name}-zip-dir"
      {
        nativeBuildInputs = [
          strip-nondeterminism
          zip
        ];
      }
      ''
        cp -r "${electron.dist}" ./electron-dist
        chmod -R u+w ./electron-dist
        cd electron-dist

        mkdir -p "$out"
        zip -Xr "$out/${zipName}" .
        strip-nondeterminism "$out/${zipName}"

        # depend on the original so that the garbage collector doesn't clean up
        # the dependencies of files inside the zip file
        echo "${electron.dist}" > "$out/.orig"
      '';
in
{
  dir = electron.dist;
  zip = zipDir + "/" + zipName;
  zipDir = zipDir;
}
