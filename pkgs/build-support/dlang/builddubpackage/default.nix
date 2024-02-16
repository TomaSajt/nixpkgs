{
  lib,
  stdenv,
  makeDubDep,
  dub,
  ldc,
  removeReferencesTo,
}:

# TODO: create proper documentation
# until then you can ping @TomaSajt if you have any questions

{
  dubDeps,
  extraDubDeps ? [ ],
  dubBuildType ? "release",
  dubFlags ? [ ],
  compiler ? ldc,
  ...
}@args:

let
  combinedDeps = (import dubDeps { inherit makeDubDep; }) ++ extraDubDeps;
in
stdenv.mkDerivation (
  builtins.removeAttrs args [
    "dubDeps"
    "extraDubDeps"
  ]
  // {
    nativeBuildInputs = args.nativeBuildInputs or [ ] ++ [
      dub
      compiler
      removeReferencesTo
    ];

    postUnpack = ''
      # the dependencies need to be placed into a deterministic location, because
      # the source file paths are included in the final binaries
      export DUB_DEPS="$NIX_BUILD_TOP/.dub-deps"
      mkdir -p $DUB_DEPS

      ${lib.concatMapStringsSep "\n" (dep: ''
        cp -r --no-preserve=all ${dep.src} $DUB_DEPS/${dep.pname}
      '') combinedDeps}

      ${args.postUnpack or ""}
    '';

    preConfigure = ''
      ${args.preConfigure or ""}

      export DUB_HOME=$(mktemp -d)

      # register dependencies
      ${lib.concatMapStringsSep "\n" (dep: ''
        dub add-local $DUB_DEPS/${dep.pname} ${dep.version}
      '') combinedDeps}
    '';

    buildPhase =
      args.buildPhase or ''
        runHook preBuild

        dub build --skip-registry=all --compiler=${lib.getExe compiler} --build=${dubBuildType} ${toString dubFlags}

        runHook postBuild
      '';

    preFixup = ''
      ${args.preFixup or ""}

      find "$out" -type f -exec remove-references-to -t ${compiler} '{}' +
    '';

    disallowedReferences = [ compiler ];

    meta = {
      platforms = dub.meta.platforms;
    } // args.meta or { };
  }
)
