{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  mpi,
  gfortran,
  blas,
  metis,
  parmetis,
}:

assert (!blas.isILP64);

let
in
stdenv.mkDerivation (finalAttrs: {
  pname = "superlu-dist";
  version = "9.0.0";

  src = fetchFromGitHub {
    owner = "xiaoyeli";
    repo = "superlu_dist";
    rev = "v${finalAttrs.version}";
    hash = "sha256-uN+qod9WuNV5cBMYIvgFM51Jf9WbFw6T8OvNCAa83S8=";
  };

  nativeBuildInputs = [
    cmake
    gfortran
    mpi
  ];

  buildInputs = [ metis ];

  propagatedBuildInputs = [ blas ];

  cmakeFlags = [
    (lib.cmakeFeature "TPL_PARMETIS_LIBRARIES" "-L${lib.getLib parmetis}/lib/libparmetis.a")
    (lib.cmakeFeature "TPL_PARMETIS_INCLUDE_DIRS" "${lib.getDev parmetis}/include")
    #"-DBUILD_SHARED_LIBS=true"
    #"-DUSE_XSDK_DEFAULTS=true"
  ];

  doCheck = true;

  checkTarget = "test";

  meta = {

  };
})
