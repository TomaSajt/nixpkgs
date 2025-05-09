{
  callPackage,
  copyDesktopItems,
  electron,
  fetchFromGitHub,
  fetchNpmDeps,
  lib,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
  stdenv,
  buildNpmPackage,
  npmHooks,
  nodejs,
  steam-run-free,
}:

buildNpmPackage (finalAttrs: {
  pname = "bs-manager";
  version = "1.5.3";

  src = fetchFromGitHub {
    owner = "Zagrios";
    repo = "bs-manager";
    tag = "v${finalAttrs.version}";
    hash = "sha256-thqz6sFmov5py7mUBYUC6ANBgjnNFC1hfLEsaxJVYu8=";
  };

  patches = [
    ./wine-inherit-env.patch
    ./use-proton-wine-on-nixos.patch
  ];

  postPatch = ''
    # don't search for resource is electron's resource directory, but our own
    substituteInPlace src/main/services/utils.service.ts \
      --replace-fail "process.resourcesPath" "'$out/share/bs-manager/resources'"

    # replace vendored DepotDownloader with our own
    rm assets/scripts/DepotDownloader
    ln -s ${finalAttrs.passthru.depotdownloader}/bin/DepotDownloader assets/scripts/DepotDownloader
  '';

  npmDepsHash = "sha256-VsCbz7ImDnJ0tonVhA4lOPA0w//tqF4hLhrReLUqYI8=";

  makeCacheWritable = true;

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  npmRebuildFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  preBuild = ''
    pushd release/app
    cp -r ${finalAttrs.passthru.extraNodeModules}/node_modules node_modules
    chmod -R u+w node_modules
    npm run postinstall
    popd
  '';

  postBuild = ''
    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist

    npm exec electron-builder -- \
      --dir \
      --config=electron-builder.config.js \
      -c.electronDist=electron-dist \
      -c.electronVersion=${electron.version}
  '';

  installPhase = ''
    runHook preInstall

    for icon in build/icons/png/*.png; do
      install -Dm644 $icon $out/share/icons/hicolor/$(basename $icon .png)/apps/bs-manager.png
    done

    mkdir -p $out/share/bs-manager
    cp -r release/build/*-unpacked/{locales,resources{,.pak}} $out/share/bs-manager

    makeWrapper ${lib.getExe electron} $out/bin/bs-manager \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --add-flags $out/share/bs-manager/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --prefix PATH : ${lib.makeBinPath [ steam-run-free ]} \
      --inherit-argv0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      desktopName = "BSManager";
      name = "BSManager";
      exec = "bs-manager";
      terminal = false;
      type = "Application";
      icon = "bs-manager";
      mimeTypes = [
        "x-scheme-handler/bsmanager"
        "x-scheme-handler/beatsaver"
        "x-scheme-handler/bsplaylist"
        "x-scheme-handler/modelsaber"
        "x-scheme-handler/web+bsmap"
      ];
      categories = [
        "Utility"
        "Game"
      ];
    })
  ];

  passthru.updateScript = nix-update-script { };

  passthru.extraNodeModules = stdenv.mkDerivation (nodeFinalAttrs: {
    name = "bs-manager-${finalAttrs.version}-extra-node-modules";

    inherit (finalAttrs) src;
    sourceRoot = "${nodeFinalAttrs.src.name}/release/app";

    npmFlags = [ "--ignore-scripts" ];

    nativeBuildInputs = [
      npmHooks.npmConfigHook
      nodejs
    ];

    npmDeps = fetchNpmDeps {
      name = "bs-manager-${finalAttrs.version}-extra-npm-deps";
      inherit (nodeFinalAttrs) src sourceRoot;
      hash = "sha256-JqDsv9kvYnbJdNwXN1EbppSrFVqr2cSnVhV2+8uw54g=";
    };

    installPhase = ''
      runHook preInstall

      # ensure the prebuilt deps match the non-prebuilt deps
      grep '"version": "${finalAttrs.passthru.query-process.version}"' node_modules/query-process/package.json
      grep '"version": "${finalAttrs.passthru.resvg-js.version}"' node_modules/@resvg/resvg-js/package.json
      rm -r node_modules/query-process
      rm -r node_modules/@resvg
      ln -s ${finalAttrs.passthru.query-process}/lib/node_modules/query-process node_modules/query-process
      ln -s ${finalAttrs.passthru.resvg-js}/lib/node_modules/@resvg node_modules/@resvg

      mkdir -p $out
      cp -r node_modules $out/node_modules

      runHook postInstall
    '';
  });

  passthru.depotdownloader = callPackage ./depotdownloader { };
  passthru.query-process = callPackage ./query-process { };
  passthru.resvg-js = callPackage ./resvg-js { };

  meta = {
    changelog = "https://github.com/Zagrios/bs-manager/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    description = "Your Beat Saber Assistant";
    homepage = "https://github.com/Zagrios/bs-manager";
    license = lib.licenses.gpl3Only;
    mainProgram = "bs-manager";
    maintainers = with lib.maintainers; [
      mistyttm
      Scrumplex
    ];
    platforms = lib.platforms.linux;
  };
})
