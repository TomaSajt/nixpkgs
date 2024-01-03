{ lib
, stdenv
, fetchsvn
, ant
, jdk8 # jdk8 is needed for building, but the game runs on newer jres as well
, jre
, makeWrapper
, makeDesktopItem
, copyDesktopItems
, canonicalize-jars-hook
, nixosTests
}:

let
  desktopItem = makeDesktopItem {
    name = "domination";
    desktopName = "Domination";
    exec = "domination";
    icon = "domination";
  };
  editorDesktopItem = makeDesktopItem {
    name = "domination-map-editor";
    desktopName = "Domination Map Editor";
    exec = "domination-map-editor";
    icon = "domination";
  };
in
stdenv.mkDerivation {
  pname = "domination";
  version = "1.2.9";

  # The .zip releases do not contain the build.xml file
  src = fetchsvn {
    url = "https://svn.code.sf.net/p/domination/code/Domination";
    # There are no tags in the repository.
    # Look for commits like "new version x.y.z info on website"
    # or "website update for x.y.z".
    rev = "2470";
    hash = "sha256-ghq7EGg++mTOzA3ASzXhk97fzy5/n9vyaRzxp12X3/4=";
  };

  nativeBuildInputs = [
    ant
    jdk8
    makeWrapper
    copyDesktopItems
    canonicalize-jars-hook
  ];

  buildPhase = ''
    runHook preBuild
    cd swingUI
    ant
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pushd build/game

    # Remove unnecessary files and launchers (they'd need to be wrapped anyway)
    rm -r src.zip *.sh *.cmd *.exe *.app *.command lib/._*

    mkdir -p $out/share/domination
    cp -r * $out/share/domination/

    install -Dm644 resources/icon.png $out/share/pixmaps/domination.png

    popd

    # Reimplement the two launchers mentioned in Unix_shortcutSpec.xml with makeWrapper
    makeWrapper ${jre}/bin/java $out/bin/domination \
      --chdir "$out/share/domination" \
      --add-flags "-jar $out/share/domination/Domination.jar"
    makeWrapper ${jre}/bin/java $out/bin/domination-map-editor \
      --chdir "$out/share/domination" \
      --add-flags "-cp $out/share/domination/Domination.jar net.yura.domination.ui.swinggui.SwingGUIFrame"

    runHook postInstall
  '';

  desktopItems = [
    desktopItem
    editorDesktopItem
  ];

  passthru.tests = {
    domination-starts = nixosTests.domination;
  };

  meta = with lib; {
    homepage = "https://domination.sourceforge.net/";
    downloadPage = "https://domination.sourceforge.net/download.shtml";
    description = "A game that is a bit like the board game Risk or RisiKo";
    longDescription = ''
      Domination is a game that is a bit like the well known board game of Risk
      or RisiKo. It has many game options and includes many maps.
      It includes a map editor, a simple map format, multiplayer network play,
      single player, hotseat, 5 user interfaces and many more features.
    '';
    sourceProvenance = with sourceTypes; [
      fromSource
      binaryBytecode # source bundles dependencies as jars
    ];
    license = licenses.gpl3Plus;
    mainProgram = "domination";
    maintainers = with maintainers; [ fgaz ];
    platforms = platforms.all;
  };
}
