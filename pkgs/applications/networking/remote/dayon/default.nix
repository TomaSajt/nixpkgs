{ lib
, stdenv
, fetchFromGitHub
, ant
, jdk
, jre
, makeWrapper
, canonicalize-jars-hook
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dayon";
  version = "13.0.0";

  src = fetchFromGitHub {
    owner = "RetGal";
    repo = "dayon";
    rev = "v${finalAttrs.version}";
    hash = "sha256-2Fo+LQvsrDvqEudZxzQBtJHGxrRYUyNyhrPV1xS49pQ=";
  };

  nativeBuildInputs = [
    ant
    jdk
    makeWrapper
    canonicalize-jars-hook
  ];

  buildPhase = ''
    runHook preBuild
    ant
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 resources/dayon.png $out/share/icons/hicolor/128x128/apps/dayon.png
    install -Dm644 resources/deb/*.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/*.desktop \
      --replace "/usr/bin/dayon/dayon.png" "dayon"

    install -Dm644 build/dayon.jar $out/share/dayon/dayon.jar
    # jre is in PATH because dayon needs keytool to generate certificates
    makeWrapper ${jre}/bin/java $out/bin/dayon \
      --prefix PATH : "${lib.makeBinPath [ jre ]}" \
      --add-flags "-jar $out/share/dayon/dayon.jar"
    makeWrapper ${jre}/bin/java $out/bin/dayon_assisted \
      --prefix PATH : "${lib.makeBinPath [ jre ]}" \
      --add-flags "-cp $out/share/dayon/dayon.jar mpo.dayon.assisted.AssistedRunner"
    makeWrapper ${jre}/bin/java $out/bin/dayon_assistant \
      --prefix PATH : "${lib.makeBinPath [ jre ]}" \
      --add-flags "-cp $out/share/dayon/dayon.jar mpo.dayon.assistant.AssistantRunner"

    runHook postInstall
  '';

  meta = with lib; {
    description = "An easy to use, cross-platform remote desktop assistance solution";
    homepage = "https://retgal.github.io/Dayon/index.html";
    license = licenses.gpl3Plus; # https://github.com/RetGal/Dayon/issues/59
    mainProgram = "dayon";
    maintainers = with maintainers; [ fgaz ];
    platforms = platforms.all;
  };
})
