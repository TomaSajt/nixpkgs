{ lib
, stdenv
, mkDerivation
, fetchurl
, fetchFromGitHub
, makeDesktopItem
, copyDesktopItems
, cmake
, boost183
, zlib
, openssl
, R
, qtbase
, qtxmlpatterns
, qtsensors
, qtwebengine
, qtwebchannel
, quarto
, libuuid
, hunspellDicts
, unzip
, ant
, jdk
, gnumake
, pandoc
, llvmPackages
, yaml-cpp
, soci
, postgresql
, nodejs_20
, qmake
, server ? false # build server version
, sqlite
, pam
, nixosTests
, npmHooks
, fetchNpmDeps
, electron
, zip
, git
}:

let
  pname = "RStudio";
  version = "2024.09.1+394";
  RSTUDIO_VERSION_MAJOR = lib.versions.major version;
  RSTUDIO_VERSION_MINOR = lib.versions.minor version;
  RSTUDIO_VERSION_PATCH = lib.versions.patch version;
  RSTUDIO_VERSION_SUFFIX = "+" + toString (
    lib.tail (lib.splitString "+" version)
  );

  src = fetchFromGitHub {
    owner = "rstudio";
    repo = "rstudio";
    rev = "v" + version;
    hash = "sha256-sHP9KKGlFJ4omgV29cf5rCdMs4SJxk9G186ZMSYBUPc=";
  };

  mathJaxSrc = fetchurl {
    url = "https://s3.amazonaws.com/rstudio-buildtools/mathjax-27.zip";
    hash = "sha256-xWy6psTOA8H8uusrXqPDEtL7diajYCVHcMvLiPsgQXY=";
  };

  rsconnectSrc = fetchFromGitHub {
    owner = "rstudio";
    repo = "rsconnect";
    rev = "v1.3.2";
    hash = "sha256-Fz0rBQVAomP6pJ/tY3lR4j7W7scMJDM2JaNob1NK6NU=";
  };

  # Ideally, rev should match the rstudio release name.
  # e.g. release/rstudio-mountain-hydrangea
  quartoSrc = fetchFromGitHub {
    owner = "quarto-dev";
    repo = "quarto";
    rev = "release/rstudio-cranberry-hibiscus";
    hash = "sha256-Tv9MPv6zRd94YgACn+lN48V2n8lNx+AdCJg+RUgrt7o=";
  };

  description = "Set of integrated tools for the R language";
in
(if server then stdenv.mkDerivation else mkDerivation)
  (rec {
    inherit pname version src RSTUDIO_VERSION_MAJOR RSTUDIO_VERSION_MINOR RSTUDIO_VERSION_PATCH RSTUDIO_VERSION_SUFFIX;

    nativeBuildInputs = [
      cmake
      unzip
      ant
      jdk
      pandoc
      nodejs_20
      (nodejs_20.python.withPackages (ps: [ ps.setuptools ]))
      zip
      git
      npmHooks.npmConfigHook
    ] ++ lib.optionals (!server) [
      copyDesktopItems
    ];


    buildInputs = [
      boost183
      zlib
      openssl
      R
      libuuid
      yaml-cpp
      soci
      postgresql
      quarto
    ] ++ (if server then [
      sqlite.dev
      pam
    ] else [
      qtbase
      qtxmlpatterns
      qtsensors
      qtwebengine
      qtwebchannel
    ]);

    env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

    npmRoot = "src/node/desktop";

    npmDeps = fetchNpmDeps {
      name = "${pname}-${version}-npm-deps";
      inherit src;
      sourceRoot = "${src.name}/${npmRoot}";
      hash = "sha256-XmmurwYXOb1H1ihNGpPPwqrQvbb1Gc/tG9eVywZixh8=";
    };

    cmakeFlags = [
      "-DNODEJS=${lib.getExe' nodejs_20 "node"}"
      "-DNPM=${lib.getExe' nodejs_20 "npm"}"
      "-DRSTUDIO_TARGET=${if server then "Server" else "Electron"}"
      "-DRSTUDIO_USE_SYSTEM_SOCI=ON"
      "-DRSTUDIO_USE_SYSTEM_BOOST=ON"
      "-DRSTUDIO_USE_SYSTEM_YAML_CPP=ON"
      "-DRSTUDIO_DISABLE_CHECK_FOR_UPDATES=ON"
      "-DQUARTO_ENABLED=TRUE"
      "-DPANDOC_VERSION=${pandoc.version}"
      "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}/lib/rstudio"
      "-DOS_RELEASE_PRETTY_NAME=nixpkgs"
    ] ++ lib.optionals (!server) [
      "-DQT_QMAKE_EXECUTABLE=${qmake}/bin/qmake"
    ];


  # Hack RStudio to only use the input R and provided libclang.
    patches = [
      ./r-location.patch
      ./clang-location.patch
      ./use-system-node.patch
    #  ./fix-resources-path.patch
      ./pandoc-nix-path.patch
      ./use-system-quarto.patch
      ./ignore-etc-os-release.patch
    ];

    postPatch = ''
      substituteInPlace src/node/desktop/CMakeLists.txt \
        --replace-fail 'include("''${CMAKE_CURRENT_LIST_DIR}/../CMakeNodeTools.txt")' ""

      substituteInPlace src/cpp/core/r_util/REnvironmentPosix.cpp --replace-fail '@R@' ${R}

      substituteInPlace src/gwt/build.xml \
        --replace-fail '@node@' ${nodejs_20} \
        --replace-fail './lib/quarto' ${quartoSrc}

      substituteInPlace src/cpp/conf/rsession-dev.conf \
        --replace-fail '@node@' ${nodejs_20}

      substituteInPlace src/cpp/core/libclang/LibClang.cpp \
        --replace-fail '@libclang@' ${lib.getLib llvmPackages.libclang} \
        --replace-fail '@libclang.so@' ${lib.getLib llvmPackages.libclang}/lib/libclang.so

      substituteInPlace src/cpp/session/CMakeLists.txt \
        --replace-fail '@pandoc@' ${pandoc} \
        --replace-fail '@quarto@' ${quarto} \
        --replace-fail \$\{CMAKE_CURRENT_SOURCE_DIR\}/../../gwt/lib/quarto ${quartoSrc}

      substituteInPlace src/cpp/session/include/session/SessionConstants.hpp \
        --replace-fail '@pandoc@' ${pandoc}/bin \
        --replace-fail '@quarto@' ${quarto}

      substituteInPlace package/linux/CMakeLists.txt \
        --replace-fail 'elseif(RSTUDIO_ELECTRON)' 'else()'
    '';

    postConfigure = ''
      pushd ../$npmRoot

      substituteInPlace package.json \
        --replace-fail "npm ci && " ""

      # electron files need to be writable on Darwin
      cp -r ${electron.dist} electron-dist
      chmod -R u+w electron-dist

      pushd electron-dist
      zip -0Xqr ../electron.zip .
      popd

      rm -r electron-dist

      # force @electron/packager to use our electron instead of downloading it, even if it is a different version
      substituteInPlace node_modules/@electron/packager/src/index.js \
        --replace-fail 'await this.getElectronZipPath(downloadOpts)' '"electron.zip"'

      popd
    '';

    hunspellDictionaries = lib.filter lib.isDerivation (lib.unique (lib.attrValues hunspellDicts));
    # These dicts contain identically-named dict files, so we only keep the
    # -large versions in case of clashes
    largeDicts = lib.filter (d: lib.hasInfix "-large-wordlist" d.name) hunspellDictionaries;
    otherDicts = lib.filter
      (d: !(lib.hasAttr "dictFileName" d &&
        lib.elem d.dictFileName (map (d: d.dictFileName) largeDicts)))
      hunspellDictionaries;
    dictionaries = largeDicts ++ otherDicts;

    preConfigure = ''
      mkdir dependencies/dictionaries
      for dict in ${builtins.concatStringsSep " " dictionaries}; do
        for i in "$dict/share/hunspell/"*; do
          ln -s $i dependencies/dictionaries/
        done
      done

      unzip -q ${mathJaxSrc} -d dependencies/mathjax-27

      # As of Cranberry Hibiscus, node 20.15.1 is used for runtime
      # node_20 can be used for build.
      # And now the folder name needs the suffix -patched. More info:
      # https://github.com/rstudio/rstudio/commit/bde8d20a9426c45ced6fde2557d75fb94ab5724e
      mkdir -p dependencies/common/node/20.15.1-patched

      mkdir -p dependencies/pandoc/${pandoc.version}
      cp ${pandoc}/bin/pandoc dependencies/pandoc/${pandoc.version}/pandoc

      cp -r ${rsconnectSrc} dependencies/rsconnect
      ( cd dependencies && ${R}/bin/R CMD build -d --no-build-vignettes rsconnect )
    '';

    postInstall = ''
      mkdir -p $out/bin $out/share

      ${lib.optionalString (!server) ''
        install -Dm644 $src/src/node/desktop/resources/freedesktop/icons/48x48/rstudio.png $out/share/icons/hicolor/48x48/apps/rstudio.png
      ''}

    '';

    meta = {
      broken = (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64);
      inherit description;
      homepage = "https://www.rstudio.com/";
      license = lib.licenses.agpl3Only;
      maintainers = with lib.maintainers; [ ciil cfhammill ];
      mainProgram = "rstudio" + lib.optionalString server "-server";
      platforms = lib.platforms.linux;
    };

    passthru = {
      inherit server;
      tests = { inherit (nixosTests) rstudio-server; };
    };
  } // lib.optionalAttrs (!server) {
    qtWrapperArgs = [
      "--suffix PATH : ${lib.makeBinPath [ gnumake ]}"
    ];

    desktopItems = [
      (makeDesktopItem {
        name = pname;
        exec = "rstudio %F";
        icon = "rstudio";
        desktopName = "RStudio";
        genericName = "IDE";
        comment = description;
        categories = [ "Development" ];
        mimeTypes = [
          "text/x-r-source" "text/x-r" "text/x-R" "text/x-r-doc" "text/x-r-sweave" "text/x-r-markdown"
          "text/x-r-html" "text/x-r-presentation" "application/x-r-data" "application/x-r-project"
          "text/x-r-history" "text/x-r-profile" "text/x-tex" "text/x-markdown" "text/html"
          "text/css" "text/javascript" "text/x-chdr" "text/x-csrc" "text/x-c++hdr" "text/x-c++src"
        ];
      })
    ];
  })
