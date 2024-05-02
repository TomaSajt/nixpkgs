{
  lib,
  buildPythonPackage,
  petsc,
  mpi,
  setuptools,
  cython,
  numpy,
}:

buildPythonPackage {
  pname = "petsc4py";
  pyproject = true;
  inherit (petsc) version src;

  preConfigure = ''
    cd src/binding/petsc4py
  '';

  env.PETSC_DIR = "${petsc}";

  nativeBuildInputs = [ mpi ];

  build-system = [
    setuptools
    cython
  ];

  dependencies = [ numpy ];

  pythonImportsCheck = [ "petsc4py" ];
}
