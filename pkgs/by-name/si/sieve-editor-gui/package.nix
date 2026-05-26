{
  lib,
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  electron,
  mkElectronDist,
  makeDesktopItem,
  copyDesktopItems,
}:

buildNpmPackage {
  pname = "sieve-editor-gui";
  version = "0.6.1-unstable-2025-03-12";

  src = fetchFromGitHub {
    owner = "thsmi";
    repo = "sieve";
    rev = "4bcefba15314177521a45a833e53969b50f4351e";
    hash = "sha256-jR3+YaVQ+Yd2Xm40SzQNvwWMPe0mJ6bhT96hlUz3/qU=";
  };

  npmDepsHash = "sha256-w2i7XsTx3hlsh/JbvShaxvDyFGcBpL66lMy7KL2tnzM=";

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ copyDesktopItems ];

  npmBuildScript = "gulp";
  npmBuildFlags = [ "app:package" ];

  installPhase = ''
    runHook preInstall
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    mv build/ $out

    install -D $out/electron/resources/libs/icons/linux.png $out/share/icons/hicolor/64x64/apps/sieve.png

    makeWrapper ${lib.getExe electron} $out/bin/sieve-editor-gui \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --add-flags $out/electron/resources/main_esm.js
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    npx electron-packager ./build/electron/resources \
      --electron-zip-dir ${(mkElectronDist electron).zipDir} \
      --electron-version ${electron.version} \
      --icon src/common/icons/mac.icns

    mkdir -p $out/Applications
    cp -r sieve-darwin-*/sieve.app $out/Applications/

    makeWrapper $out/Applications/sieve.app/Contents/MacOS/Sieve $out/bin/sieve-editor-gui
  ''
  + ''
    runHook postInstall
  '';

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
  };

  desktopItems = [
    (makeDesktopItem {
      name = "sieve-editor-gui";
      exec = "sieve-editor-gui";
      desktopName = "Sieve Editor";
      icon = "sieve";
      categories = [
        "Utility"
        "Email"
      ];
      comment = "Tool to Manage Sieve Message Filters";
    })
  ];

  meta = {
    description = "Activate, edit, delete and add Sieve scripts with a convenient interface";
    homepage = "https://github.com/thsmi/sieve";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [
      Silver-Golden
      fugi
    ];
    mainProgram = "sieve-editor-gui";
    inherit (electron.meta) platforms;
  };
}
