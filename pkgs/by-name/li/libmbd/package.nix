{ stdenv
, fetchFromGitHub
, lib
, cmake
, mpi
, blas
, lapack
, scalapack
, gfortran
} :

assert !blas.isILP64;
assert !lapack.isILP64;

stdenv.mkDerivation (finalAttrs: {
  pname = "libmbd";
  version = "0.12.8";

  src = fetchFromGitHub {
    owner = "libmbd";
    repo = "libmbd";
    rev = finalAttrs.version;
    hash = "sha256-ctUaBLPaZHoV1rU3u1idvPLGbvC9Z17YBxYKCaL7EMk=";
  };

  preConfigure = ''
    cat > cmake/libMBDVersionTag.cmake << EOF
      set(VERSION_TAG "${finalAttrs.version}")
    EOF
  '';

  nativeBuildInputs = [ cmake gfortran ];

  buildInputs = [ blas lapack scalapack ];

  propagatedBuildInputs = [ mpi ];

  meta = with lib; {
    description = "Many-body dispersion library";
    homepage = "https://github.com/libmbd/libmbd";
    license = licenses.mpl20;
    platforms = platforms.linux;
    maintainers = [ maintainers.sheepforce ];
  };
})
