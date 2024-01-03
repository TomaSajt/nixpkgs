# Canonicalize the manifest & repack with deterministic timestamps.
canonicalizeJar() {
    local input="$1"
    echo "canonicalizing $input"
    mkdir -p "$input-tmp"
    pushd "$input-tmp" >/dev/null
    # Uses 7zz to extract jar to avoid the zipbomb-detection of unzip
    # -y: confirm prompt when encountering overlapped files
    @zz@ x "$input" -y >/dev/null
    if [ -f "META-INF/MANIFEST.MF" ]; then
        canonicalizeJarManifest "META-INF/MANIFEST.MF"
    fi
    # Sets all timestamps to Jan 1 1980, the earliest mtime zips support.
    find . -exec touch -t 198001010000.00 {} +
    # -q|--quiet, -r|--recurse-paths
    # -o|--latest-time: canonicalizes overall archive mtime
    # -X|--no-extra: don't store platform-specific extra file attribute fields
    rm "$input"
    @zip@ -qroX "$input" .
    popd >/dev/null
    rm -rf "$input-tmp"
}

# See also the Java specification's JAR requirements:
# https://docs.oracle.com/javase/8/docs/technotes/guides/jar/jar.html#Notes_on_Manifest_and_Signature_Files
# TODO: implement if necessary
# originally it did the following: keep first line and sort every other line
# however, this did not respect the fact that attributes can span multiple lines
# this is a NOOP for now
# if any package has some non-deterministic attribute order a proper parsing script is needed
canonicalizeJarManifest() {
    local input="$1"
}
