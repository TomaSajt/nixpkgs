{ lib
, stdenv
, fetchurl
, fetchzip
, ant
, jdk
, makeWrapper
, canonicalize-jars-hook
, xdg-utils
, gnused
, callPackage
}:

let
  newsPlugin = fetchurl {
    url = "https://www.tvbrowser.org/data/uploads/1372016422809_543/NewsPlugin.jar";
    hash = "sha256-5XoypuMd2AFBE2SJ6EdECuvq6D81HLLuu9UoA9kcKAM=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "tvbrowser";
  version = "4.2.7";

  src = fetchzip {
    url = "downloads.sourceforge.net/tvbrowser/tvbrowser_${finalAttrs.version}_src.zip";
    hash = "sha256-dmNfI6T0MU7UtMH+C/2hiAeDwZlFCB4JofQViZezoqI=";
  };

  nativeBuildInputs = [
    ant
    jdk
    makeWrapper
    canonicalize-jars-hook
  ];

  postPatch = ''
    # Reminder: paths to the nix store inside jars can't be detected automatically, so use programs from $PATH
    substituteInPlace src/tvbrowser/core/protocolhandler/ProtocolHandler.java \
        --replace "/usr/bin/xdg-mime" "xdg-mime" \
        --replace "/usr/bin/xdg-desktop-menu" "xdg-desktop-menu" \
        --replace "/usr/bin/sed" "sed" \
        --replace "/usr/share/tvbrowser" $out/share/tvbrowser \
        --replace "/usr/share/applications" $out/share/applications
  '';

  buildPhase = ''
    runHook preBuild

    ant runtime-linux -Dnewsplugin.url=file://${newsPlugin}
    ant tvbrowser-desktop-entry

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/tvbrowser
    cp -R runtime/tvbrowser_linux/* $out/share/tvbrowser

    mkdir -p $out/share/applications
    mv -t $out/share/applications $out/share/tvbrowser/tvbrowser.desktop
    substituteInPlace $out/share/applications/tvbrowser.desktop \
        --replace "=imgs" "=$out/share/tvbrowser/imgs" \
        --replace "=tvbrowser.sh" "=$out/bin/tvbrowser"

    for i in 16 32 48 128; do
      mkdir -p "$out/share/icons/hicolor/"$i"x"$i"/apps"
      ln -s "$out/share/tvbrowser/imgs/tvbrowser"$i".png" \
          "$out/share/icons/hicolor/"$i"x"$i"/apps/tvbrowser.png"
    done

    makeWrapper $out/share/tvbrowser/tvbrowser.sh $out/bin/tvbrowser \
        --prefix PATH : ${lib.makeBinPath [ jdk xdg-utils gnused ]} \
        --prefix XDG_DATA_DIRS : $out/share \
        --set PROGRAM_DIR $out/share/tvbrowser

    runHook postInstall
  '';

  passthru.tests.startwindow = callPackage ./test.nix { };

  meta = with lib; {
    description = "Electronic TV Program Guide";
    downloadPage = "https://www.tvbrowser.org/index.php?id=tv-browser";
    homepage = "https://www.tvbrowser.org/";
    changelog = "https://www.tvbrowser.org/index.php?id=news";
    sourceProvenance = with sourceTypes; [ binaryBytecode fromSource ];
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    mainProgram = "tvbrowser";
    maintainers = with maintainers; [ yarny tomasajt ];
    longDescription = ''
      TV-Browser shows TV program data arranged like in printed
      TV programs after downloading it from the internet.
      Plugins are used to download program data
      and to provide additional functionality.
    '';
  };
})
