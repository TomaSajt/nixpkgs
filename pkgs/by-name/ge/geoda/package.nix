{
  lib,
  stdenv,
  callPackage,
  fetchFromGitHub,
  boost,
  wxGTK32,
  curl,
  gdal,
  eigen,
  libGL,
}:

let
  json-spirit = callPackage ./json-spirit.nix { };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "geoda";
  version = "1.22.0.6";

  src = fetchFromGitHub {
    owner = "GeoDaCenter";
    repo = "geoda";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Fc2mgfSJhM1Vci6ZzkUbf/8UFEGXMyZTnCL+X8ujxzQ=";
  };

  # Note:
  # weirdly, the GeoDamake.opt file is in .gitignore, but was not removed from the sources
  # so you'll need to remove the file from .gitignore to regenerate this patch
  patches = [ ./make.patch ];

  stictDeps = true;

  nativeBuildInputs = [ wxGTK32 ];

  buildInputs = [
    boost
    wxGTK32
    curl
    gdal
    json-spirit
    eigen
    libGL
  ];

  env.NIX_CFLAGS_COMPILE = "-I${lib.getDev eigen}/include/eigen3";

  preBuild = ''
    mkdir o
  '';

  installPhase = ''
    runHook preInstall

    dir -R

    runHook postInstall
  '';

  passthru = {
    inherit json-spirit;
  };

  meta = {
    description = "An introduction to spatial data analysis";
    homepage = "http://geodacenter.github.io/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ tomasajt ];
  };
})
