{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  substituteAll,
  petsc,
  mpi,
  setuptools,
  cython_0,
  numpy,
  decorator,
  mpi4py,
  petsc4py,
  pytools,
  cachetools,
  packaging,
  loopy,
  pytestCheckHook,
  mpiCheckPhaseHook,
  flake8,
  openssh,
  lapack,
}:

buildPythonPackage rec {
  pname = "pyop2";
  version = "20240312.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "OP2";
    repo = "PyOP2";
    rev = "Firedrake_${version}";
    hash = "sha256-s81NTnKQCBblvimhOnck8ZI7ADdQH4jaOYkUADq6oaM=";
  };

  patches = [
    (substituteAll {
      src = ./set-pyop2-mpi.patch;
      inherit mpi;
    })
    ./pyop2-inherit-petsc4py-config.patch
  ];

  buildInputs = [
    mpi
    lapack
  ];

  build-system = [
    setuptools
    cython_0
  ];

  dependencies = [
    petsc4py
    (mpi4py.override { inherit mpi; })
    numpy
    decorator
    pytools
    cachetools
    packaging # maybe build-system only
    loopy # should be the firedrake fork
  ];

  nativeCheckInputs = [
    pytestCheckHook
    flake8
    openssh
    mpiCheckPhaseHook
  ];

  # TODO: fix tests
  disabledTests = [
    "test_dat_illegal_set"
    "test_dat_illegal_name"
    "test_dat_illegal_name"
    "test_dat_illegal_name"
  ];

  preConfigure = ''
    export HOME=$(mktemp -d)
  '';

  preCheck = ''
    rm -r pyop2
  '';

  pythonImportsCheck = [ "pyop2" ];

  meta = {
    inherit (petsc.meta) license homepage;
    description = "Python bindings for PETSc";
    maintainers = with lib.maintainers; [ tomasajt ];
  };
}
