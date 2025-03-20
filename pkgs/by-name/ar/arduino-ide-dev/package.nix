{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  makeWrapper,
  callPackage,
  replaceVars,
  runCommand,

  yarnConfigHook,
  nodejs,
  protobuf,
  pkg-config,

  electron,
  libX11,
  libxkbfile,
  libsecret,
  grpc-tools,

  linkFarm,
  ripgrep,
}:
let
  # unpack tarball containing electron's headers
  electron-headers = runCommand "electron-headers" { } ''
    mkdir -p $out
    tar -C $out --strip-components=1 -xvf ${electron.headers}
  '';

  examples_src = fetchFromGitHub {
    owner = "arduino";
    repo = "arduino-examples";
    rev = "1.10.0";
    hash = "sha256-V/r/NBR26cAf1+jmCU2cj9K6Yc+ewQUguAap2c0kdqg=";
  };

  inherit (callPackage ./plugins.nix { }) theiaPlugins;

  pluginsDir = linkFarm "arduino-ide-plugins-dir" (
    lib.mapAttrsToList (name: path: { inherit name path; }) theiaPlugins
  );
in

stdenv.mkDerivation (finalAttrs: {
  pname = "arduino-ide";
  version = "unstable-2024-01-22";

  src = fetchFromGitHub {
    owner = "arduino";
    repo = "arduino-ide";
    rev = "0e7b0c94863cd948a1f77f5090e0affb3fe6804f";
    hash = "sha256-LrwwMvxwFxLQ6ncOqjo3qt6kyr/Ettp8Jk7cwFn6RYw=";
  };

  patches = [
    (replaceVars ./electron.patch {
      electron_dist = electron.dist;
      electron_version = electron.version;
      build_date = "2024-01-22T00:00:00.000Z";
      version = "2.2.2-${finalAttrs.version}";
    })
    (replaceVars ./dont-download-ide-extension-binaries.patch {
      inherit examples_src;
    })
    ./disable-plugin-download.patch
  ];

  yarnOfflineCache = fetchYarnDeps {
    inherit (finalAttrs) src;
    hash = "sha256-ANd/Ug8w8HdMfeTegzMtnYhXjlQ65OfeD0bU8CgwIOs=";
  };

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    PUPPETEER_SKIP_DOWNLOAD = "1";
  };

  nativeBuildInputs = [
    yarnConfigHook
    nodejs
    (nodejs.python.withPackages (ps: [ ps.setuptools ]))
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
    substituteInPlace package.json \
      --replace-fail '"node": ">=18.17.0 <21"' ""
  '';

  dontYarnInstallDeps = true;

  postConfigure = ''
    cp yarn.lock arduino-ide-extension/yarn.lock
    cp yarn.lock electron-app/yarn.lock

    yarnConfigHook

    pushd arduino-ide-extension
    #yarnConfigHook
    popd
    pushd electron-app
    #yarnConfigHook
    popd

    # don't download prebuilt binaries
    substituteInPlace node_modules/grpc-tools/package.json \
      --replace-fail '"install"' '"_install"'
    ln -s ${grpc-tools}/bin/protoc node_modules/grpc-tools/bin/protoc
    ln -s ${grpc-tools}/bin/grpc_node_plugin node_modules/grpc-tools/bin/grpc_node_plugin


    echo yarn install \
        --frozen-lockfile \
        --force \
        --production=false \
        --ignore-engines \
        --ignore-platform \
        --ignore-scripts \
        --no-progress \
        --non-interactive \
        --offline

    patchShebangs node_modules arduino-ide-extension/node_modules electron-app/node_modules

    ls -la node_modules
    rm -r node_modules/@vscode/windows-ca-certs

    pushd node_modules/@theia/ffmpeg
    substituteInPlace lib/ffmpeg.js --replace-fail "path.resolve(require.resolve('electron/package.json'), '..', 'dist')" "'${electron.dist}'" # bruh moment'
    substituteInPlace lib/replace-ffmpeg.js --replace-fail "let shouldDownload = true;" "return;"
    substituteInPlace lib/check-ffmpeg.js --replace-fail "checkFfmpeg(options = {}) {" "checkFfmpeg(options = {}) { return;"
    popd
  '';

  buildPhase = ''
    export npm_config_nodedir=${electron-headers}

    npm rebuild --verbose

    pushd arduino-ide-extension
      npm rebuild --verbose
    popd
    yarn --offline prepare
    yarn --offline --cwd arduino-ide-extension --offline build
    yarn --offline --cwd electron-app --offline rebuild
    yarn --offline --cwd electron-app --offline build
    yarn --offline --cwd electron-app --offline package
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/arduino-ide
    cp -r electron-app/dist/*-unpacked/{locales,resources{,.pak}} $out/share/arduino-ide

    makeWrapper ${lib.getExe electron} $out/bin/arduino-ide \
      --add-flags $out/share/arduino-ide/resources/app.asar \
      --inherit-argv0

    runHook postInstall
  '';

  passthru = { inherit theiaPlugins pluginsDir; };

})
