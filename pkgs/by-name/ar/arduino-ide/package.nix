{ lib
, gcc10Stdenv
, fetchFromGitHub
, fetchYarnDeps
, substituteAll
, makeWrapper
, callPackage

, prefetch-yarn-deps
, yarn
, nodejs
, python3
, electron_27
, protobuf
, pkg-config
, libX11
, libxkbfile
, libsecret
, grpc-tools
, linkFarm
, ripgrep
, applyPatches
}:
let
  electron = electron_27;
  version = "unstable-2024-01-22";

  orig_src = fetchFromGitHub {
    owner = "arduino";
    repo = "arduino-ide";
    rev = "0e7b0c94863cd948a1f77f5090e0affb3fe6804f";
    hash = "sha256-LrwwMvxwFxLQ6ncOqjo3qt6kyr/Ettp8Jk7cwFn6RYw=";
  };

  src = applyPatches {
    src = orig_src;
    # Fixes the "undefined symbol" error with drivelist
    # Sadly, I couldn't get the other ones to work
    patches = [ ./update-drivelist.patch ];
  };


  examples_src = fetchFromGitHub {
    owner = "arduino";
    repo = "arduino-examples";
    rev = "1.10.0";
    hash = "sha256-V/r/NBR26cAf1+jmCU2cj9K6Yc+ewQUguAap2c0kdqg=";
  };

  inherit (callPackage ./plugins.nix { }) theiaPlugins;
  pluginsDir = linkFarm "arduino-ide-plugins-dir" (lib.mapAttrsToList (name: path: { inherit name path; }) theiaPlugins);
in

gcc10Stdenv.mkDerivation (finalAttrs: {
  pname = "arduino-ide";
  inherit version src;

  patches = [
    (substituteAll {
      src = ./electron.patch;
      electron_dist = "${electron}/libexec/electron";
      electron_version = electron.version;
      build_date = "2024-01-22T00:00:00.000Z";
      version = "2.2.2-${version}";
    })
    (substituteAll {
      src = ./dont-download-ide-extension-binaries.patch;
      inherit examples_src;
    })
    ./disable-plugin-download.patch
  ];

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${src}/yarn.lock";
    hash = "sha256-F8dCyvPoOpqjxe7DFHQkxnC3xFIyItk0r7vkk4xv48I=";
  };

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    PUPPETEER_SKIP_DOWNLOAD = "1";
  };

  nativeBuildInputs = [
    prefetch-yarn-deps
    yarn
    python3
    nodejs
    nodejs.pkgs.node-gyp
    nodejs.pkgs.node-gyp-build
    nodejs.pkgs.node-pre-gyp
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    libX11
    libxkbfile
    libsecret
    protobuf
  ];

  postPatch = ''
    ln -s ${pluginsDir} electron-app/plugins
    substituteInPlace package.json --replace '"prepare":' '"_prepare":'
  '';

  buildPhase = ''

    export HOME=$(mktemp -d)
    fixup-yarn-lock yarn.lock
    yarn config --offline set yarn-offline-mirror $yarnOfflineCache

    mkdir -p $HOME/.node-gyp/${nodejs.version}
    echo 9 > $HOME/.node-gyp/${nodejs.version}/installVersion
    ln -sfv ${nodejs}/include $HOME/.node-gyp/${nodejs.version}
    export npm_config_nodedir=${nodejs}

    export PATH=$PWD/node_modules/.bin:$PATH
    yarn install --offline --frozen-lockfile --ignore-scripts --ignore-engines --no-progress
    patchShebangs node_modules

    cp -r node_modules/grpc-tools temp-grpc-tools

    yarn install --offline --frozen-lockfile --ignore-engines --no-progress
    patchShebangs node_modules

    cp -r temp-grpc-tools node_modules/grpc-tools
    ln -s ${grpc-tools}/bin/protoc node_modules/grpc-tools/bin/protoc
    ln -s ${grpc-tools}/bin/grpc_node_plugin node_modules/grpc-tools/bin/grpc_node_plugin

    mkdir node_modules/@vscode/ripgrep/bin
    ln -s ${ripgrep}/bin/rg node_modules/@vscode/ripgrep/bin/rg

    pushd node_modules/@theia/ffmpeg
    substituteInPlace lib/ffmpeg.js --replace "path.resolve(require.resolve('electron/package.json'), '..', 'dist')" "'${electron}/libexec/electron'" # bruh moment'
    substituteInPlace lib/replace-ffmpeg.js --replace "let shouldDownload = true;" "return;"
    substituteInPlace lib/check-ffmpeg.js --replace "checkFfmpeg(options = {}) {" "checkFfmpeg(options = {}) { return;"
    popd

    yarn _prepare

    pushd arduino-ide-extension
    yarn install --offline --frozen-lockfile --ignore-engines --no-progress
    patchShebangs node_modules
    yarn --offline build
    popd

    pushd electron-app
    yarn install --offline --frozen-lockfile --ignore-engines --no-progress
    patchShebangs node_modules
    yarn --offline rebuild
    yarn --offline build
    yarn --offline package
    popd

  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/arduino-ide
    cp -r electron-app/dist/*-unpacked/{locales,resources{,.pak}} $out/share/arduino-ide

    makeWrapper ${electron}/bin/electron $out/bin/arduino-ide \
        --add-flags $out/share/arduino-ide/resources/app.asar \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
        --inherit-argv0

    runHook postInstall
  '';

  passthru = { inherit theiaPlugins pluginsDir; };

})
