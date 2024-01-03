{ lib
, stdenv
, fetchFromGitHub
, ant
, jdk
, makeWrapper
, wrapGAppsHook
, makeDesktopItem
, copyDesktopItems
, canonicalize-jars-hook
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pattypan";
  version = "22.03";

  src = fetchFromGitHub {
    owner = "yarl";
    repo = "pattypan";
    rev = "v${finalAttrs.version}";
    hash = "sha256-wMQrBg+rEV1W7NgtWFXZr3pAxpyqdbEBKLNwDDGju2I=";
  };

  nativeBuildInputs = [
    ant
    jdk
    makeWrapper
    wrapGAppsHook
    copyDesktopItems
    canonicalize-jars-hook
  ];

  dontWrapGApps = true;

  buildPhase = ''
    runHook preBuild
    export JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF8"
    ant

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm644 pattypan.jar -t $out/share/java
    runHook postInstall
  '';

  # gappsWrapperArgs is set in preFixup
  postFixup = ''
    makeWrapper ${jdk}/bin/java $out/bin/pattypan \
        ''${gappsWrapperArgs[@]} \
        --add-flags "-jar $out/share/java/pattypan.jar"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "pattypan";
      exec = "pattypan";
      desktopName = "Pattypan";
      genericName = "An uploader for Wikimedia Commons";
      categories = [ "Utility" ];
    })
  ];

  meta = {
    description = "An uploader for Wikimedia Commons";
    homepage = "https://commons.wikimedia.org/wiki/Commons:Pattypan";
    license = lib.licenses.mit;
    mainProgram = "pattypan";
    maintainers = with lib.maintainers; [ fee1-dead ];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
    ];
  };
})
