{
  lib,
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  makeDesktopItem,
  copyDesktopItems,
  zip,
  makeWrapper,
  electron,
}:

let
  zipSufixes = {
    "x86_64-linux" = "linux-x64";
    "aarch64-linux" = "linux-arm64";
    "x86_64-darwin" = "darwin-x64";
    "aarch64-darwin" = "darwin-arm64";
  };

  zipSuffix = zipSufixes.${stdenv.system};

  electronDist = electron + (if stdenv.isDarwin then "/Applications" else "/libexec/electron");
in
buildNpmPackage rec {
  pname = "git-it";
  version = "5.2.2-unstable-2024-06-03";

  src = fetchFromGitHub {
    owner = "Git-it-App";
    repo = "git-it-electron";
    rev = "f97a73004a608445546c38597dbd468a82fb2854";
    hash = "sha256-IE7Af+GfBwPaOicOa+gvnVgnHS3A1fYy2+3w4Y/Y6Bc=";
  };

  npmDepsHash = "sha256-APru01xj0WS3e6KdPwmyrnt18IzbevGPRRTgyO+70Pk=";

  nativeBuildInputs = [
    zip
    makeWrapper
  ] ++ lib.optionals (!stdenv.isDarwin) [ copyDesktopItems ];

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  # disable code signing on Darwin
  env.CSC_IDENTITY_AUTO_DISCOVERY = "false";

  # Create a local cache of electron zip-files, so electron-packager can copy from it
  postConfigure = ''
    mkdir local-cache

    # electron files need to be writable on Darwin
    cp -r ${electronDist} electron-dist
    chmod -R u+w electron-dist

    pushd electron-dist
    zip -qr ../local-cache/electron-v${electron.version}-${zipSuffix}.zip *
    popd
  '';

  postBuild = ''
    npm exec electron-packager -- \
        . Git-it \
        --electronZipDir=local-cache \
        --electronVersion=${electron.version} \
        --overwrite \
        --out=out \
        --extraResource=resources/i18n/ \
        --ignore=.github/ \
        --ignore=resources/ \
        ${lib.optionalString stdenv.isDarwin "--icon=assets/git-it.icns"}
  '';

  installPhase = ''
    runHook preInstall

    ${lib.optionalString (!stdenv.isDarwin) ''
      mkdir -p $out/share/git-it
      cp -r out/*/{locales,resources{,.pak}} $out/share/git-it
      makeWrapper ${lib.getExe electron} $out/bin/git-it \
          --add-flags $out/share/git-it/resources/app.asar \
          --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
          --inherit-argv0
    ''}

    ${lib.optionalString stdenv.isDarwin ''
      mkdir -p $out/Applications
      cp -r out/*/Git-it.app $out/Applications
      makeWrapper $out/Applications/Git-it.app/Contents/MacOS/Git-it $out/bin/git-it
    ''}

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "git-it";
      desktopName = "Git-it";
      exec = "git-it";
      icon = "git-it";
      comment = meta.description;
    })
  ];

  meta = {
    changelog = "";
    description = "";
    homepage = "";
    license = [ ]; # lib.licenses.agpl3Only;
    mainProgram = "git-it";
    maintainers = with lib.maintainers; [ tomasajt ];
    platforms = lib.attrNames zipSufixes;
  };
}
