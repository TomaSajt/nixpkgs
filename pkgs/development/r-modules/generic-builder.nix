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

args:

stdenv.mkDerivation (
  {
    name = "r-${args.name or "${args.pname}-${args.version}"}";

    strictDeps = true;

    nativeBuildInputs =
      (args.nativeBuildInputs or [ ])
      ++ [
        R
        gettext
      ]
      ++ lib.optionals (args.requireX or false) [
        util-linux
        xvfb-run
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        gfortran
      ];

    buildInputs =
      (args.buildInputs or [ ])
      ++ [
        R
        gettext
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        gfortran
        libiconv
      ];

    enableParallelBuilding = true;

    env = (args.env or { }) // {
      NIX_CFLAGS_COMPILE =
        (args.env.NIX_CFLAGS_COMPILE or "")
        + lib.optionalString stdenv.hostPlatform.isDarwin " -I${lib.getInclude stdenv.cc.libcxx}/include/c++/v1";
    };

    configurePhase = ''
      runHook preConfigure

      export MAKEFLAGS+="''${enableParallelBuilding:+-j$NIX_BUILD_CORES}"
      export R_LIBS_SITE="$R_LIBS_SITE''${R_LIBS_SITE:+:}$out/library"

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild
      runHook postBuild
    '';

    installFlags =
      (args.installFlags or [ ]) ++ (if (args.doCheck or true) then [ ] else [ "--no-test-load" ]);

    rCommand =
      if (args.requireX or false) then
        # Unfortunately, xvfb-run has a race condition even with -a option, so that
        # we acquire a lock explicitly.
        "flock ${xvfb-run} xvfb-run -a -e xvfb-error R"
      else
        "R";

    checkPhase = ''
      # noop since R CMD INSTALL tests packages
    '';

    installPhase = ''
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
    + (args.postFixup or "");
  }
  // (lib.removeAttrs args [
    "name"
    "nativeBuildInputs"
    "buildInputs"
    "env"
    "installFlags"
    "postFixup"
  ])
)
