{ lib
, stdenv
, fetchFromGitHub
, autoreconfHook
, libewf
, afflib
, openssl
, zlib
, jdk
, perl
, ant
}:

let
  version = "4.12.1";

  src = fetchFromGitHub {
    owner = "sleuthkit";
    repo = "sleuthkit";
    rev = "sleuthkit-${version}";
    hash = "sha256-q51UY2lIcLijycNaq9oQIwUXpp/1mfc3oPN4syOPF44=";
  };

  # Fetch libraries using a fixed output derivation
  rdeps = stdenv.mkDerivation {
    name = "sleuthkit-${version}-deps";

    inherit src; # WIP WIP WIP

    nativeBuildInputs = [ ant jdk ];

    # unpack, build, install
    dontConfigure = true;

    buildPhase = ''
      export IVY_HOME=$NIX_BUILD_TOP/.ant
      pushd bindings/java
      ant retrieve-deps
      popd
      pushd case-uco/java
      ant get-ivy-dependencies
      popd
    '';

    installPhase = ''
      mkdir -m 755 -p $out/bindings/java
      cp -r bindings/java/lib $out/bindings/java
      mkdir -m 755 -p $out/case-uco/java
      cp -r case-uco/java/lib $out/case-uco/java
      cp -r $IVY_HOME/lib $out
      chmod -R 755 $out/lib
    '';

    outputHashMode = "recursive";
    outputHash = "sha256-mc/KQrwn3xpPI0ngOLcpoQDaJJm/rM8XgaX//5PiRZk=";
    outputHashAlgo = "sha256";
  };
in
stdenv.mkDerivation {
  pname = "sleuthkit";
  inherit version src;

  postPatch = ''
    substituteInPlace tsk/img/ewf.cpp --replace libewf_handle_read_random libewf_handle_read_buffer_at_offset
  '';

  nativeBuildInputs = [
    autoreconfHook
    jdk
    perl
    ant
    rdeps
  ];

  buildInputs = [
    libewf
    afflib
    openssl
    zlib
  ];

  enableParallelBuilding = true;

  preConfigure = ''
    export IVY_HOME="$NIX_BUILD_TOP/.ant"
    export JAVA_HOME="${jdk}"
    export ant_args="-Doffline=true -Ddefault-jar-location=$IVY_HOME/lib"

    # pre-positioning these jar files allows -Doffline=true to work
    mkdir -p source/{bindings,case-uco}/java $IVY_HOME
    cp -r ${rdeps}/bindings/java/lib source/bindings/java
    chmod -R 755 source/bindings/java
    cp -r ${rdeps}/case-uco/java/lib source/case-uco/java
    chmod -R 755 source/case-uco/java
    cp -r ${rdeps}/lib $IVY_HOME
    chmod -R 755 $IVY_HOME
  '';

  # Hack to fix the RPATH
  preFixup = ''
    rm -rf */.libs
  '';

  passthru = { inherit rdeps; };

  meta = with lib; {
    description = "A forensic/data recovery tool";
    homepage = "https://www.sleuthkit.org/";
    changelog = "https://github.com/sleuthkit/sleuthkit/releases/tag/${src.rev}";
    maintainers = with maintainers; [ raskin gfrascadorio ];
    platforms = platforms.linux;
    sourceProvenance = with sourceTypes; [
      fromSource
      binaryBytecode # dependencies
    ];
    license = licenses.ipl10;
  };
}
