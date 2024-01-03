{ lib
, stdenv
, fetchFromGitHub
, ant
, jdk8
, makeWrapper
, canonicalize-jars-hook
}:

let
  jdk = jdk8;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ili2c";
  version = "5.1.1";

  nativeBuildInputs = [
    ant
    jdk
    makeWrapper
    canonicalize-jars-hook
  ];

  src = fetchFromGitHub {
    owner = "claeis";
    repo = "ili2c";
    rev = "ili2c-${finalAttrs.version}";
    hash = "sha256-FHhx+f253+UdbFjd2fOlUY1tpQ6pA2aVu9CBSwUVoKQ=";
  };

  patches = [
    # stops the build date being included in Version.properties
    # Also, modifying a .properties file changes the first line to the current timestamp
    ./dont-use-build-timestamp.patch
  ];

  buildPhase = ''
    runHook preBuild
    ant jar
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 build/jar/ili2c.jar -t $out/share/java
    makeWrapper ${jdk.jre}/bin/java $out/bin/ili2c \
        --add-flags "-jar $out/share/java/ili2c.jar"

    runHook postInstall
  '';

  meta = with lib; {
    description = "The INTERLIS Compiler";
    longDescription = ''
      Checks the syntactical correctness of an INTERLIS data model.
    '';
    homepage = "https://www.interlis.ch/downloads/ili2c";
    sourceProvenance = with sourceTypes; [
      fromSource
      binaryBytecode # source bundles dependencies as jars
    ];
    license = licenses.lgpl21Plus;
    maintainers = [ maintainers.das-g ];
    platforms = platforms.linux;
    mainProgram = "ili2c";
  };
})
