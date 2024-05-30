{
  lib,
  stdenv,
  overrideSDK,
  buildNpmPackage,
  fetchFromGitHub,
  electron_28,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  libpng,
  libX11,
  libXi,
  libXtst,
  zlib,
  darwin,
}:

let
  inherit (darwin.apple_sdk_11_0.frameworks)
    ApplicationServices
    Carbon
    CoreFoundation
    CoreGraphics
    Foundation
    OpenGL
    ;

  electron = electron_28;
  electronDist = electron + (if stdenv.isDarwin then "/Applications" else "/libexec/electron");

  buildNpmPackage' = buildNpmPackage.override {
    stdenv = if stdenv.isDarwin then overrideSDK stdenv "11.0" else stdenv;
  };
in
buildNpmPackage' rec {
  pname = "mattermost-desktop";
  version = "5.8.0";

  src = fetchFromGitHub {
    owner = "mattermost";
    repo = "desktop";
    rev = "refs/tags/v${version}";
    hash = "sha256-P0FmxHExhMF4BDGWfZEXvYBp4NKUj5hDL+KGUnfgP74=";
  };

  # VERSION is calculated using the git command, however if isRelease is true the value won't ever get used
  # so we set VERSION to any arbitrary value and force isRelease to be true
  postPatch = ''
    substituteInPlace webpack.config.base.js \
        --replace-fail 'const VERSION =' 'const VERSION = ""; //' \
        --replace-fail 'const isRelease =' 'const isRelease = true; //'
  '';

  npmDepsHash = "sha256-uPXiCNX7Sbw8yC35+iOUOC/ukir7Xv4bpYn33xj1xy0=";

  npmFlags = [
    "--legacy-peer-deps"
    # skip initial native module builds (will get rebuilt by electron-builder anyway)
    # this allows us to first patch some files
    "--ignore-scripts"
  ];

  makeCacheWritable = true;

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  # don't check Apple SDK version with `xcrun` (would check if at least 11.0)
  env.MACOS_NOTIFICATION_STATE_NO_SDK_CHECK = "1";

  nativeBuildInputs = [ makeWrapper ] ++ lib.optionals (!stdenv.isDarwin) [ copyDesktopItems ];

  buildInputs =
    lib.optionals stdenv.isLinux [
      # robotjs node-gyp dependencies
      libpng
      libX11
      libXi
      libXtst
      zlib
    ]
    ++ lib.optionals stdenv.isDarwin [
      # robotjs node-gyp dependencies
      ApplicationServices
      Carbon
      CoreFoundation
      OpenGL
      # macos-notification-state node-gyp dependencies
      CoreFoundation
      CoreGraphics
      Foundation
      # Intents
    ];

  # the Intents framework is missing a symbol (INFocusStatusCenter)
  # so rebuild without supporting it
  preBuild = ''
    substituteInPlace node_modules/macos-notification-state/binding.gyp \
        --replace-fail '-weak_framework Intents' ""
    substituteInPlace node_modules/macos-notification-state/lib/focus-center.mm \
        --replace-fail '__has_include("Intents/Intents.h")' 'false'
    npm rebuild macos-notification-state --verbose
  '';

  npmBuildScript = "build-prod";

  postBuild = ''
    cp -r ${electronDist} electron-dist
    chmod -R u+w electron-dist

    npm exec electron-builder -- \
      --dir \
      -c.electronDist=electron-dist \
      -c.electronVersion=${electron.version}
  '';

  installPhase = ''
    runHook preInstall

    ${lib.optionalString stdenv.isDarwin ''
      mkdir -p $out/Applications
      cp -r release/mac*/Mattermost.app $out/Applications
      makeWrapper $out/Applications/Mattermost.app/Contents/MacOS/Mattermost $out/bin/mattermost-desktop
    ''}

    ${lib.optionalString (!stdenv.isDarwin) ''
      mkdir -p $out/share/mattermost-desktop
      cp -r release/*-unpacked/{locales,resources{,.pak}} $out/share/mattermost-desktop

      install -Dm644 src/assets/linux/app_icon.png $out/share/icons/hicolor/512x512/apps/mattermost-desktop.png

      makeWrapper '${lib.getExe electron}' $out/bin/mattermost-desktop \
        --add-flags $out/share/mattermost-desktop/resources/app.asar \
        --set-default ELECTRON_IS_DEV 0 \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"
    ''}

    runHook postInstall
  '';

  # based on ${src}/src/assets/linux/create_desktop_file.sh
  desktopItems = [
    (makeDesktopItem {
      name = "Mattermost";
      desktopName = "Mattermost";
      exec = "mattermost-desktop";
      icon = "mattermost-desktop";
      comment = meta.description;
      terminal = false;
      mimeTypes = [ "x-scheme-handler/mattermost" ];
      categories = [
        "Network"
        "InstantMessaging"
      ];
    })
  ];

  meta = with lib; {
    description = "Mattermost Desktop client";
    mainProgram = "mattermost-desktop";
    homepage = "https://about.mattermost.com/";
    license = licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    maintainers = with maintainers; [
      joko
      tomasajt
    ];
  };
}
