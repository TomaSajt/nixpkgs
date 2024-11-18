{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  replaceVars,
  makeDesktopItem,
  copyDesktopItems,
  cmake,
  boost183,
  zlib,
  openssl,
  R,
  libsForQt5,
  quarto,
  libuuid,
  hunspellDicts,
  unzip,
  ant,
  jdk,
  gnumake,
  pandoc,
  llvmPackages,
  yaml-cpp,
  soci,
  postgresql,
  nodejs,
  server ? false, # build server version
  sqlite,
  pam,
  nixosTests,
}:

let
  mathJaxSrc = fetchurl {
    url = "https://s3.amazonaws.com/rstudio-buildtools/mathjax-27.zip";
    hash = "sha256-xWy6psTOA8H8uusrXqPDEtL7diajYCVHcMvLiPsgQXY=";
  };

  rsconnectSrc = fetchFromGitHub {
    owner = "rstudio";
    repo = "rsconnect";
    rev = "v1.2.2";
    hash = "sha256-wvM9Bm7Nb6yU9z0o+uF5lB2kdgjOW5wZSk6y48NPF2U=";
  };

  # Ideally, rev should match the rstudio release name.
  # e.g. release/rstudio-mountain-hydrangea
  quartoSrc = fetchFromGitHub {
    owner = "quarto-dev";
    repo = "quarto";
    rev = "bb264a572c6331d46abcf087748c021d815c55d7";
    hash = "sha256-lZnZvioztbBWWa6H177X6rRrrgACx2gMjVFDgNup93g=";
  };

in
stdenv.mkDerivation rec {
  pname = "RStudio";
  version = "2024.04.2+764";

  RSTUDIO_VERSION_MAJOR = lib.versions.major version;
  RSTUDIO_VERSION_MINOR = lib.versions.minor version;
  RSTUDIO_VERSION_PATCH = lib.versions.patch version;
  RSTUDIO_VERSION_SUFFIX = "+" + toString (lib.tail (lib.splitString "+" version));

  src = fetchFromGitHub {
    owner = "rstudio";
    repo = "rstudio";
    rev = "v" + version;
    hash = "sha256-j258eW1MYQrB6kkpjyolXdNuwQ3zSWv9so4q0QLsZuw=";
  };

  nativeBuildInputs =
    [
      cmake
      unzip
      ant
      jdk
      pandoc
      nodejs
    ]
    ++ lib.optionals (!server) [
      copyDesktopItems
      libsForQt5.wrapQtAppsHook
    ];

  buildInputs =
    [
      boost183
      zlib
      openssl
      R
      libuuid
      yaml-cpp
      soci
      postgresql
      quarto
    ]
    ++ (
      if server then
        [
          sqlite.dev
          pam
        ]
      else
        [
          libsForQt5.qtbase
          libsForQt5.qtxmlpatterns
          libsForQt5.qtsensors
          libsForQt5.qtwebengine
          libsForQt5.qtwebchannel
        ]
    );

  cmakeFlags =
    [
      (lib.cmakeFeature "RSTUDIO_TARGET" (if server then "Server" else "Desktop"))
      (lib.cmakeBool "RSTUDIO_USE_SYSTEM_SOCI" true)
      (lib.cmakeBool "RSTUDIO_USE_SYSTEM_BOOST" true)
      (lib.cmakeBool "RSTUDIO_USE_SYSTEM_YAML_CPP" true)
      (lib.cmakeBool "RSTUDIO_DISABLE_CHECK_FOR_UPDATES" true)
      (lib.cmakeBool "QUARTO_ENABLED" true)
      (lib.cmakeFeature "PANDOC_VERSION" pandoc.version)
      (lib.cmakeFeature "CMAKE_INSTALL_PREFIX" "${placeholder "out"}/lib/rstudio")
    ]
    ++ lib.optionals (!server) [
      (lib.cmakeFeature "QT_QMAKE_EXECUTABLE" "${libsForQt5.qmake}/bin/qmake")
    ];

  # Hack RStudio to only use the input R and provided libclang.
  patches = [
    (replaceVars ./r-location.patch {
      R = lib.getBin R;
    })
    (replaceVars ./clang-location.patch {
      libclang = lib.getLib llvmPackages.libclang;
      "libclang.so" = "${lib.getLib llvmPackages.libclang}/lib/libclang.so";
    })
    (replaceVars ./use-system-node.patch {
      node = lib.getBin nodejs;
    })
    ./fix-resources-path.patch
    # were these even correct to begin with?
    (replaceVars ./pandoc-nix-path.patch {
      pandoc = pandoc;
      quarto = quarto;
    })
    (replaceVars ./use-system-quarto.patch {
      pandoc = "${pandoc}/bin";
      quarto = quarto;
    })
    ./ignore-etc-os-release.patch
  ];

  postPatch = ''
    substituteInPlace src/gwt/build.xml \
      --replace-fail './lib/quarto' ${quartoSrc}
  '';

  hunspellDictionaries = lib.filter lib.isDerivation (lib.unique (lib.attrValues hunspellDicts));
  # These dicts contain identically-named dict files, so we only keep the
  # -large versions in case of clashes
  largeDicts = lib.filter (d: lib.hasInfix "-large-wordlist" d.name) hunspellDictionaries;
  otherDicts = lib.filter (
    d: !(lib.hasAttr "dictFileName" d && lib.elem d.dictFileName (map (d: d.dictFileName) largeDicts))
  ) hunspellDictionaries;
  dictionaries = largeDicts ++ otherDicts;

  preConfigure = ''
    mkdir dependencies/dictionaries
    for dict in ${builtins.concatStringsSep " " dictionaries}; do
      for i in "$dict/share/hunspell/"*; do
        ln -s $i dependencies/dictionaries/
      done
    done

    unzip -q ${mathJaxSrc} -d dependencies/mathjax-27

    # As of Chocolate Cosmos, node 18.20.3 is used for runtime
    # 18.18.2 is still used for build
    # see https://github.com/rstudio/rstudio/commit/facb5cf1ab38fe77813aaf36590804e4f865d780
    mkdir -p dependencies/common/node/18.20.3

    mkdir -p dependencies/pandoc/${pandoc.version}
    cp ${pandoc}/bin/pandoc dependencies/pandoc/${pandoc.version}/pandoc

    cp -r ${rsconnectSrc} dependencies/rsconnect
    ( cd dependencies && ${R}/bin/R CMD build -d --no-build-vignettes rsconnect )
  '';

  postInstall = ''
    mkdir -p $out/bin $out/share

    ${lib.optionalString (!server) ''
      mkdir -p $out/share/icons/hicolor/48x48/apps
      ln $out/lib/rstudio/rstudio.png $out/share/icons/hicolor/48x48/apps
    ''}

    for f in {${
      if server then
        "crash-handler-proxy,postback,r-ldpath,rpostback,rserver,rserver-pam,rsession,rstudio-server"
      else
        "diagnostics,rpostback,rstudio"
    }}; do
      ln -s $out/lib/rstudio/bin/$f $out/bin
    done

    for f in .gitignore .Rbuildignore LICENSE README; do
      find . -name $f -delete
    done

    rm -r $out/lib/rstudio/{INSTALL,COPYING,NOTICE,README.md,SOURCE,VERSION}
  '';

  qtWrapperArgs = lib.optionals (!server) [
    "--suffix PATH : ${lib.makeBinPath [ gnumake ]}"
  ];

  desktopItems = lib.optionals (!server) [
    (makeDesktopItem {
      name = "RStudio";
      exec = "rstudio %F";
      icon = "rstudio";
      desktopName = "RStudio";
      genericName = "IDE";
      comment = meta.description;
      categories = [ "Development" ];
      mimeTypes = [
        "text/x-r-source"
        "text/x-r"
        "text/x-R"
        "text/x-r-doc"
        "text/x-r-sweave"
        "text/x-r-markdown"
        "text/x-r-html"
        "text/x-r-presentation"
        "application/x-r-data"
        "application/x-r-project"
        "text/x-r-history"
        "text/x-r-profile"
        "text/x-tex"
        "text/x-markdown"
        "text/html"
        "text/css"
        "text/javascript"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-c++hdr"
        "text/x-c++src"
      ];
    })
  ];

  meta = {
    broken = (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64);
    description = "Set of integrated tools for the R language";
    homepage = "https://www.rstudio.com/";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [
      ciil
      cfhammill
    ];
    mainProgram = "rstudio" + lib.optionalString server "-server";
    platforms = lib.platforms.linux;
  };

  passthru = {
    inherit server;
    tests = {
      inherit (nixosTests) rstudio-server;
    };
  };
}
