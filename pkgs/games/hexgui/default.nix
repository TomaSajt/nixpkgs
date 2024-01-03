{ lib
, stdenv
, fetchFromGitHub
, ant
, jdk
, makeWrapper
, canonicalize-jars-hook
}:

stdenv.mkDerivation {
  pname = "hexgui";
  version = "unstable-2023-1-7";

  src = fetchFromGitHub {
    owner = "selinger";
    repo = "hexgui";
    rev = "62f07ff51db0d4a945ad42f86167cc2f2ce65d90";
    hash = "sha256-yEdZs9HUt3lcrdNO1OH8M8g71+2Ltf+v1RR1fKRDV0o=";
  };

  nativeBuildInputs = [
    ant
    jdk
    makeWrapper
    canonicalize-jars-hook # fix mainfest creation timestamp
  ];

  installPhase = ''
    install -Dm644 lib/hexgui.jar -t $out/share/java
    makeWrapper ${jdk}/bin/java $out/bin/hexgui \
        --add-flags "-jar $out/share/java/hexgui.jar"
  '';

  meta = {
    description = "GUI for the board game Hex";
    homepage = "https://github.com/selinger/hexgui";
    license = lib.licenses.gpl3Only;
    mainProgram = "hexgui";
    maintainers = with lib.maintainers; [ ursi tomasajt ];
    platforms = lib.platforms.unix;
  };
}
