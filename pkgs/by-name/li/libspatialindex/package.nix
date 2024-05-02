{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libspatialindex";
  version = "1.9.3";

  src = fetchFromGitHub {
    owner = "libspatialindex";
    repo = "libspatialindex";
    rev = finalAttrs.version;
    hash = "sha256-39hsCWcNBjq3C3jVjxds4qGdrKX/9FlV3qnPXA5JqvA=";
  };

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "C++ implementation of R*-tree, an MVR-tree and a TPR-tree with C API";
    homepage = "https://libspatialindex.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomasajt ];
  };
})
