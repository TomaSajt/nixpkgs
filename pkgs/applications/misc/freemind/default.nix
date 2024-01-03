{ lib
, stdenv
, fetchurl
, ant
, jdk
, jre
, canonicalize-jars-hook
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "freemind";
  version = "1.0.1";

  src = fetchurl {
    url = "mirror://sourceforge/freemind/freemind-src-${finalAttrs.version}.tar.gz";
    hash = "sha256-AYKFEmsn6uc5K4w7+1E/Jb1wuZB0QOXrggnyC0+9hhk=";
  };

  nativeBuildInputs = [
    ant
    jdk
    canonicalize-jars-hook # .properties file present
  ];

  preConfigure = ''
    chmod +x check_for_duplicate_resources.sh
    sed 's,/bin/bash,${stdenv.shell},' -i check_for_duplicate_resources.sh
  '';

  buildPhase = ''
    runHook preBuild

    ## work around javac encoding errors
    export JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF8"
    ant dist

    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out/{bin,nix-support}
    cp -r ../bin/dist $out/nix-support
    sed -i 's/which/type -p/' $out/nix-support/dist/freemind.sh

    cat >$out/bin/freemind <<EOF
    #! ${stdenv.shell}
    JAVA_HOME=${jre} $out/nix-support/dist/freemind.sh
    EOF
    chmod +x $out/{bin/freemind,nix-support/dist/freemind.sh}
  '';

  meta = with lib; {
    description = "Mind-mapping software";
    homepage = "https://freemind.sourceforge.net/wiki/index.php/Main_Page";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
})
