cargoSetupPostUnpackHook() {
    echo "Executing cargoSetupPostUnpackHook"

    # TODO: Maybe remove as it's barely used.
    eval "${cargoDepsHook-}"

    # Some cargo builds need to modify their own vendor dependencies.
    # This copies the vendor directory into the build tree and makes it writable.
    if [ -z $cargoVendorDir ]; then
        if [ ! -d "$cargoDeps" ]; then
            echo "ERROR: cargoSetupHook only supports unpacked directories for cargoDeps"
            echo "Hint: Use the official fetchCargoVendor fetcher"
            exit 1
        fi

        cargoDepsCopy="$NIX_BUILD_TOP/$(stripHash "$cargoDeps")"
        cp -Lr --reflink=auto -- "$cargoDeps" "$cargoDepsCopy"
        chmod -R +644 -- "$cargoDepsCopy"

        # Move .cargo directory to the top of the build directory
        # so that cargo can detect it from anywhere.
        mv "$cargoDepsCopy/.cargo" "$NIX_BUILD_TOP/"
    else
        cargoDepsCopy="$NIX_BUILD_TOP/$sourceRoot/${cargoRoot:+$cargoRoot/}${cargoVendorDir}"
        mkdir -p "$NIX_BUILD_TOP/.cargo"
        # TODO: In most cases the package already has its own .cargo/config.toml
        #       that correctly sets the used vendor directory.
        #       In these cases doing this essentially affects nothing.
        #       You could even set cargoVendorDir to anything.
        cat @defaultConfig@ > "$NIX_BUILD_TOP/.cargo/config.toml"
    fi

    substituteInPlace "$NIX_BUILD_TOP/.cargo/config.toml" \
      --subst-var-by vendor "$cargoDepsCopy"

    cat >> "$NIX_BUILD_TOP/.cargo/config.toml" <<'EOF'
# The following section was added by cargoSetupHook
@cargoConfig@
EOF

    echo "Finished cargoSetupPostUnpackHook"
}

# After unpacking and applying patches, check that the Cargo.lock matches our
# src package. Note that we do this after the patchPhase, because the
# patchPhase may create the Cargo.lock if upstream has not shipped one.
cargoSetupPostPatchHook() {
    echo "Executing cargoSetupPostPatchHook"

    cargoDepsLockfile="$cargoDepsCopy/Cargo.lock"
    srcLockfile="$(pwd)/${cargoRoot:+$cargoRoot/}Cargo.lock"

    echo "Validating consistency between $srcLockfile and $cargoDepsLockfile"
    if ! @diff@ $srcLockfile $cargoDepsLockfile; then

      # If the diff failed, first double-check that the file exists, so we can
      # give a friendlier error msg.
      if ! [ -e $srcLockfile ]; then
        echo "ERROR: Missing Cargo.lock from src. Expected to find it at: $srcLockfile"
        echo "Hint: You can use the cargoPatches attribute to add a Cargo.lock manually to the build."
        exit 1
      fi

      if ! [ -e $cargoDepsLockfile ]; then
        echo "ERROR: Missing lockfile from cargo vendor. Expected to find it at: $cargoDepsLockfile"
        exit 1
      fi

      echo
      echo "ERROR: cargoHash or cargoSha256 is out of date"
      echo
      echo "Cargo.lock is not the same in $cargoDepsCopy"
      echo
      echo "To fix the issue:"
      echo '1. Set cargoHash/cargoSha256 to an empty string: `cargoHash = "";`'
      echo '2. Build the derivation and wait for it to fail with a hash mismatch'
      echo '3. Copy the "got: sha256-..." value back into the cargoHash field'
      echo '   You should have: cargoHash = "sha256-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=";'
      echo

      exit 1
    fi

    unset cargoDepsCopy

    echo "Finished cargoSetupPostPatchHook"
}

if [ -z "${dontCargoSetupPostUnpack-}" ]; then
  postUnpackHooks+=(cargoSetupPostUnpackHook)
fi

if [ -z ${cargoVendorDir-} ]; then
  postPatchHooks+=(cargoSetupPostPatchHook)
fi
