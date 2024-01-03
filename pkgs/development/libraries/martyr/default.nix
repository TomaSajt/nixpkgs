{ lib
, stdenv
, fetchurl
, ant
, jdk
, canonicalize-jars-hook
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "martyr";
  version = "0.3.9";

  src = fetchurl {
    url = "mirror://sourceforge/martyr/martyr-${finalAttrs.version}.tar.gz";
    hash = "sha256-qXwSScGd+3PBvj/Y1nf5W/KJtjox4DoLGX6xNQKRSM8=";
  };

  buildInputs = [
    ant
    jdk
    canonicalize-jars-hook # fix manifest creation date
  ];

  buildPhase = ''
    runHook preBuild
    ant
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm644 martyr.jar -t $out/share/java
    runHook postInstall
  '';

  meta = {
    description = "Java framework around the IRC protocol to allow application writers easy manipulation of the protocol and client state";
    homepage = "https://martyr.sourceforge.net/";
    license = lib.licenses.lgpl21;
  };
})
