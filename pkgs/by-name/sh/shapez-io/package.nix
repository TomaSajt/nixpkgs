{ lib
, stdenv
, fetchFromGitHub
, fetchYarnDeps
, nodejs
, yarn
, prefetch-yarn-deps
, pkg-config

, autoconf
, zlib
, libpng
, libjpeg
, pngquant
, gifsicle
, optipng
}:

stdenv.mkDerivation rec {
  pname = "shapez-io";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "tobspr-games";
    repo = "shapez.io";
    rev = version;
    hash = "sha256-7eA1cLTroauVi1/wZPkxfkDEd0yjzk7Dy+rVlemilyg=";
  };

  sourceRoot = "${src.name}/gulp";

  nativeBuildInputs = [
    nodejs
    yarn
    prefetch-yarn-deps
    #pkg-config
    #autoconf
  ];

  buildInputs = [
    #zlib
    #libpng
  ];

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${src}/gulp/yarn.lock";
    hash = "sha256-/KJ4dVexv0CIREvoCsmIbRM+uZUY22agyrV1FgF/FnY=";
  };

  buildPhase = ''
    export HOME=$(mktemp -d)
    yarn config --offline set yarn-offline-mirror ${yarnOfflineCache}
    fixup-yarn-lock yarn.lock

    yarn install --offline --frozen-lockfile \
        --ignore-engines --ignore-scripts --no-progress
    patchShebangs node_modules


    mkdir node_modules/jpegtran-bin/vendor
    sed -i "/src(/d" node_modules/{jpegtran-bin,pngquant-bin,gifsicle,optipng-bin}/lib/index.js
    ln -s ${libjpeg}/bin/jpegtran node_modules/jpegtran-bin/vendor
    ln -s ${pngquant}/bin/pngquant node_modules/pngquant-bin/vendor
    ln -s ${gifsicle}/bin/gifsicle node_modules/gifsicle/vendor
    ln -s ${optipng}/bin/optipng node_modules/optipng-bin/vendor

    rm -r node_modules/imagemin-pngquant/node_modules/pngquant-bin
    ln -s node_modules/pngquant-bin node_modules/imagemin-pngquant/node_modules/pngquant-bin

    npm rebuild

    yarn gulp standalone.standalone-steam.package.linux64
  '';

  dontFixup = true;


}
