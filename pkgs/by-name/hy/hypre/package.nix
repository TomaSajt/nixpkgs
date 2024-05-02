{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  mpi,
  blas,
  lapack,
  enableShared ? !stdenv.hostPlatform.isStatic,
  enableComplex ? false,
  enableBigInt ? false,
  withSuperlu ? false,
  superlu,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hypre";
  version = "2.31.0";

  src = fetchFromGitHub {
    owner = "hypre-space";
    repo = "hypre";
    rev = "v${finalAttrs.version}";
    hash = "sha256-eFOyM3IzQUNm7cSnORA3NrKYotEBmLKC8mi+fcwPMQA=";
  };

  sourceRoot = "${finalAttrs.src.name}/src";

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    mpi
    blas
    lapack
  ] ++ lib.optionals withSuperlu [ superlu ];

  cmakeFlags =
    [
      (lib.cmakeBool "HYPRE_ENABLE_HYPRE_BLAS" false)
      (lib.cmakeBool "HYPRE_ENABLE_HYPRE_LAPACK" false)
      (lib.cmakeBool "HYPRE_ENABLE_SHARED" enableShared)
      (lib.cmakeBool "HYPRE_ENABLE_COMPLEX" enableComplex)
      (lib.cmakeBool "HYPRE_ENABLE_BIGINT" enableBigInt)
    ]
    ++ lib.optionals withSuperlu [
      (lib.cmakeBool "HYPRE_WITH_SUPERLU" true)
      (lib.cmakeFeature "TPL_SUPERLU_LIBRARIES" "superlu")
      (lib.cmakeFeature "TPL_SUPERLU_INCLUDE_DIRS" "${superlu}/include")
    ];

  meta = {
    description = "A library of parallel solvers for sparse linear systems featuring multigrid methods";
    homepage = "https://www.llnl.gov/casc/hypre/";
    license = with lib.licenses; [
      asl20
      # or
      mit
    ];
    maintainers = with lib.maintainers; [ tomasajt ];
  };
})
