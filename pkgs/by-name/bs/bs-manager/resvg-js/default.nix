{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,

  cargo,
  nodejs,
  npmHooks,
  rustc,
  yarn-berry_3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "resvg-js";
  version = "2.6.2";

  src = fetchFromGitHub {
    owner = "thx";
    repo = "resvg-js";
    rev = "v${finalAttrs.version}";
    hash = "sha256-KjgfuHjb1W53//Tu+Ib8Ka0Edilzsigt5ux4uOnhvO8=";
  };

  patches = [
    # also, lock the version `bytes` to 1.9.0
    # because `woff2` doesn't work with higher versions
    ./add-cargo-lock.patch
  ];

  missingHashes = ./missing-hashes.json;

  yarnOfflineCache = yarn-berry_3.fetchYarnBerryDeps {
    name = "resvg-js-${finalAttrs.version}-yarn-offline-cache";
    inherit (finalAttrs) src missingHashes;
    hash = "sha256-zncVrcyXQEPuMTB6L3OAPoWpUjV5mVrrRqiMa5cDudk=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs)
      pname
      version
      src
      patches
      ;
    hash = "sha256-YSfI+lb6y6EHyZ3lHIJZOVnX+0Q4ZXTKRROMaSXlViI=";
  };

  nativeBuildInputs = [
    cargo
    nodejs
    npmHooks.npmInstallHook
    rustc
    rustPlatform.cargoSetupHook
    yarn-berry_3
    yarn-berry_3.yarnBerryConfigHook
  ];

  buildPhase = ''
    runHook preBuild
    yarn build
    runHook postBuild
  '';

  postInstall = ''
    install -Dm755 ./*.node -t $out/lib/node_modules/@resvg/resvg-js
  '';

  meta = {
    description = "High-performance SVG renderer and toolkit";
    homepage = "https://github.com/thx/resvg-js";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
