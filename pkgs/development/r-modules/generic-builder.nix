{
  stdenv,
  lib,
  R,
  xvfb-run,
  util-linux,
  gettext,
  gfortran,
  libiconv,
}:

attrs:

stdenv.mkDerivation (
  attrs
  // {
    name = "r-${attrs.name or "${attrs.pname}-${attrs.version}"}";

    strictDeps = attrs.strictDeps or true;

    nativeBuildInputs =
      (attrs.nativeBuildInputs or [ ])
      ++ [
        R
        gettext
      ]
      ++ lib.optionals (attrs.requireX or false) [
        util-linux
        xvfb-run
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        gfortran
      ];

    buildInputs =
      (attrs.buildInputs or [ ])
      ++ [
        R
        gettext
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        gfortran
        libiconv
      ];

    enableParallelBuilding = attrs.enableParallelBuilding or true;

    env = (attrs.env or { }) // {
      NIX_CFLAGS_COMPILE =
        (attrs.env.NIX_CFLAGS_COMPILE or "")
        + lib.optionalString stdenv.hostPlatform.isDarwin " -I${lib.getInclude stdenv.cc.libcxx}/include/c++/v1";
    };

    configurePhase =
      attrs.configurePhase or ''
        runHook preConfigure

        export MAKEFLAGS+="''${enableParallelBuilding:+-j$NIX_BUILD_CORES}"
        export R_LIBS_SITE="$R_LIBS_SITE''${R_LIBS_SITE:+:}$out/library"

        runHook postConfigure
      '';

    buildPhase =
      attrs.buildPhase or ''
        runHook preBuild
        runHook postBuild
      '';

    installFlags =
      (attrs.installFlags or [ ]) ++ (if (attrs.doCheck or true) then [ ] else [ "--no-test-load" ]);

    rCommand =
      if (attrs.requireX or false) then
        # Unfortunately, xvfb-run has a race condition even with -a option, so that
        # we acquire a lock explicitly.
        "flock ${xvfb-run} xvfb-run -a -e xvfb-error R"
      else
        "R";

    checkPhase =
      attrs.checkPhase or ''
        # noop since R CMD INSTALL tests packages
      '';

    installPhase =
      attrs.installPhase or ''
        runHook preInstall
        mkdir -p $out/library
        $rCommand CMD INSTALL --built-timestamp='1970-01-01 00:00:00 UTC' $installFlags --configure-args="$configureFlags" -l $out/library .
        runHook postInstall
      '';

    postFixup = ''
      if test -e $out/nix-support/propagated-build-inputs; then
        ln -s $out/nix-support/propagated-build-inputs $out/nix-support/propagated-user-env-packages
      fi
    ''
    + (attrs.postFixup or "");
  }
)
