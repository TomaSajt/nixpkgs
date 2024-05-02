{
  lib,
  stdenv,
  fetchFromBitbucket,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sowing";
  version = "1.1.26-p8";

  src = fetchFromBitbucket {
    owner = "petsc";
    repo = "pkg-sowing";
    rev = "v${finalAttrs.version}";
    hash = "sha256-oh9OP5T9/9mLCVLhlzmGq5s0R1VbIQRBXbTqSJ2pr48=";
  };

  meta = {
    description = "";
    homepage = "";
    license = [ ];
    maintainers = with lib.maintainers; [ tomasajt ];
  };
})
