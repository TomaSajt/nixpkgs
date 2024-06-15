{
  fetchFromGitHub,
  fetchurl,
  fetchYarnDeps,
  electron_29,
  gcc,
  gnumake,
  makeWrapper,
  fixup-yarn-lock,
  yarn,
  nodejs,
  python3,
  lib,
  stdenv,
  libpulseaudio,
}:

let
  electron = electron_29;

  electronDist = electron + (if stdenv.isDarwin then "/Applications" else "/libexec/electron");

  ringrtc = fetchurl {
    url = "https://build-artifacts.signal.org/libraries/ringrtc-desktop-build-v2.39.3.tar.gz";
    hash = "sha256-6b7CUbEzyNkXZvwMxgyO7UjPbtncTvhPhV6odhqbWPU=";
  };

  sqlcipher = fetchurl {
    url = "https://build-artifacts.signal.org/desktop/sqlcipher-4.5.5-fts5-fix--3.0.7--0.2.1-ef53ea45ed92b928ecfd33c552d8d405263e86e63dec38e1ec63e1b0193b630b.tar.gz";
    hash = "sha256-71PqRe2SuSjs/TPFUtjUBSY+huY97Djh7GPhsBk7Yws=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "signal-desktop";
  version = "7.5.1";

  src = fetchFromGitHub {
    owner = "signalapp";
    repo = "Signal-Desktop";
    rev = "v${finalAttrs.version}";
    hash = "sha256-++XRYI36LbFDGuDJDU2qpy2NG5iOGyFxhy/gRxfHXbI=";
  };

  offlineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-15Z4MyQk8ZeP7oZ1GWoHFhSGsW222t98O7AftcnexSA=";
  };

  dangerOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/danger/yarn.lock";
    hash = "sha256-CnTZwi93xQxYCviFEnkvtVud6bj8D3wOsjafnFue0ag=";
  };

  scOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/sticker-creator/yarn.lock";
    hash = "sha256-K+8yLBrz1ianDopa5Aztg21udrHGqLB/aGMFx+tNzNw=";
  };

  nativeBuildInputs = [
    fixup-yarn-lock
    gcc
    gnumake
    makeWrapper
    nodejs
    python3
    yarn
  ];

  patches = [ ./remove-stuff.patch ];

  postPatch = ''
    substituteInPlace package.json \
      --replace-fail '"node": "20.9.0"' ""
  '';

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  configurePhase = ''
    runHook preConfigure

    export HOME=$(mktemp -d)

    configureDependencies () {
      yarn config --offline set yarn-offline-mirror $1
      fixup-yarn-lock "$2/yarn.lock"
      yarn install --offline --cwd "$2" --frozen-lockfile --ignore-platform --ignore-scripts --no-progress --non-interactive

      patchShebangs "$2/node_modules/"
    }

    configureDependencies ${finalAttrs.offlineCache} "."
    configureDependencies ${finalAttrs.dangerOfflineCache} "./danger"
    configureDependencies ${finalAttrs.scOfflineCache} "./sticker-creator"

    cp ${ringrtc} node_modules/@signalapp/ringrtc/scripts/prebuild.tar.gz
    cp ${sqlcipher} node_modules/@signalapp/better-sqlite3/deps/sqlcipher.tar.gz

    mkdir -p "$HOME/.node-gyp/${nodejs.version}"
    echo 9 >"$HOME/.node-gyp/${nodejs.version}/installVersion"
    ln -sfv "${nodejs}/include" "$HOME/.node-gyp/${nodejs.version}"
    export npm_config_nodedir=${nodejs}

    npm rebuild @signalapp/ringrtc --verbose

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    yarn --offline run generate
    yarn --offline run build:esbuild:prod

    cp -r ${electronDist} electron-dist
    chmod -R u+w electron-dist

    yarn --offline run build:release \
        --dir \
        --config.npmRebuild=true \
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
