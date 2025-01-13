{
  lib,
  fetchFromGitHub,
  fetchurl,
  fetchNpmDeps,
  nodejs,
  electron_32,
  npmHooks,
  makeWrapper,
  stdenv,
  libpulseaudio,
}:

let
  electron = electron_32;

  # IMPORTANT: if the file doesn't exactly match the expected one, it will try to download it
  ringrtc = fetchurl {
    url = "https://build-artifacts.signal.org/libraries/ringrtc-desktop-build-v2.49.1.tar.gz";
    hash = "sha256-7JEANWYhwrmQQ64NH7XEmIgZW4c+JrHOOjuvOkqxXn4=";
  };

  # IMPORTANT: if the file doesn't exactly match the expected one, it will try to download it
  sqlcipher = fetchurl {
    url = "https://build-artifacts.signal.org/desktop/sqlcipher-v2-4.6.1-signal-patch2--0.2.0-b0dbebe5b2d81879984bfa2318ba364fb4d436669ddc1668d2406eaaaee40b7e.tar.gz";
    hash = "sha256-sNvr5bLYGHmYS/ojGLo2T7TUNmad3BZo0kBuqq7kC34=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "signal-desktop";
  version = "7.37.0";

  src = fetchFromGitHub {
    owner = "signalapp";
    repo = "Signal-Desktop";
    rev = "v${finalAttrs.version}";
    hash = "sha256-02F5Srb2IX0IKxmNwcFGE+V7f34dOzVVzXdBOAFW0kU=";
  };

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-XB3yHQQcCYmWbW6w7b+9dcbCQzee4UCuQr/9ZuZzRAI=";
  };

  dangerNpmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    sourceRoot = "${finalAttrs.src.name}/danger";
    hash = "sha256-327VOX0PG6wyJbr9M7zWF9kviheFpEU9YCyL1ZklaH4";
  };

  stickerCreatorNpmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    sourceRoot = "${finalAttrs.src.name}/sticker-creator";
    hash = "sha256-xnxECrNMHCjUd71LolSz3VECEXf7B3b/3X/FsLyFO+0=";
  };

  nativeBuildInputs = [
    makeWrapper
    nodejs
    npmHooks.npmConfigHook
    nodejs.python
  ];

  # patches = [ ./remove-stuff.patch ];

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  npmFlags = [ "--ignore-scripts" ];

  preConfigure = ''
    npmRoot=danger
    npmDeps=$dangerNpmDeps
    runHook npmConfigHook

    npmRoot=sticker-creator
    npmDeps=$stickerCreatorNpmDeps
    runHook npmConfigHook
  '';

  buildPhase = ''
    runHook preBuild

    mkdir electron-headers
    tar xf ${electron.headers} -C electron-headers --strip-components=1
    export npm_config_nodedir="$(pwd)/electron-headers"

    cp ${ringrtc} node_modules/@signalapp/ringrtc/scripts/prebuild.tar.gz
    cp ${sqlcipher} node_modules/@signalapp/better-sqlite3/deps/sqlcipher.tar.gz

    #npm rebuild @signalapp/ringrtc --verbose
    npm rebuild --verbose

    npm run generate
    npm run build:esbuild:prod

    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist

    npm run build:release \
        --dir \
        --config.npmRebuild=false \
        --config.electronDist=electron-dist \
        --config.electronVersion=${electron.version}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/signal-desktop"
    cp -r release/*-unpacked/{locales,resources{,.pak}} "$out/share/signal-desktop"

    makeWrapper ${lib.getExe electron} "$out/bin/signal-desktop" \
        --add-flags "$out/share/signal-desktop/resources/app.asar" \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
        --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
        --inherit-argv0
    #'''

    patchelf "$out/share/signal-desktop/resources/app.asar.unpacked/node_modules/@signalapp/ringrtc/build/linux"/libringrtc-*.node \
        --add-needed ${libpulseaudio}/lib/libpulse.so

    runHook postInstall
  '';
})
