{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gfortran,
  mpi,
  libspatialindex,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libsupermesh";
  version = "1.0.1-unstable-2024-01-25";

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "libsupermesh";
    rev = "84becef14eb117defa49354116c04aa180471a07";
    hash = "sha256-39hsCWcNBjq3C3jVjxdD4qGdrKX/9FlV3qnPXA5JqvA=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ (lib.cmakeBool "BUILD_SHARED_LIBS" true) ];

  buildInputs = [
    gfortran
    mpi
    libspatialindex
  ];

  meta = {
    description = "";
    homepage = "";
    license = lib.licenses.lgpl21;
    maintainers = with lib.maintainers; [ tomasajt ];
  };
})
