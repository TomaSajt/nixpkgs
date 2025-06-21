{
  lib,
  stdenv,
  fetchurl,
  fltk,
  antlr2,
  libGL,
  libGLU,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gaviewer";
  version = "0.86";

  src = fetchurl {
    url = "https://geometricalgebra.org/downloads/GAViewer-${finalAttrs.version}.tar.gz";
    hash = "sha256-K9+7gJxFRT7cL73Niz0LWTfGiKxHlc6zHaTGfWV0Bs0=";
  };

  hardeningDisable = [ "format" ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=implicit-int";
  env.NIX_LDFLAGS = "-lantlr";

  buildInputs = [
    fltk
    antlr2
    libGL
    libGLU
  ];

  meta = {
    description = "";
    homepage = "";
    license = [ ];
    maintainers = with lib.maintainers; [ ];
  };
})
