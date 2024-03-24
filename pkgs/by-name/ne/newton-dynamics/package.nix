{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  glfw,
  openal,
  libX11,
  libGLU,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "newton-dynamics";
  version = "4.02-unstable-2024-03-21";

  src = fetchFromGitHub {
    owner = "MADEAPPS";
    repo = "newton-dynamics";
    rev = "c67b5feb0a3ee43987ad59a197cecaffa2094715";
    hash = "sha256-3KBZ8XHfJTtC4lNTYf+yhwuZQrhMgVveY+V2OGPyggI=";
  };

  sourceRoot = "${finalAttrs.src.name}/newton-4.00";

  patches = [ ./a.patch ];

  nativeBuildInputs = [ cmake ];

  env.NIX_CFLAGS = "-include cstdint";

  buildInputs = [
    glfw
    openal
    libX11
    libGLU
  ];

  meta = {
    description = "";
    homepage = "";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ tomasajt ];
  };
})
