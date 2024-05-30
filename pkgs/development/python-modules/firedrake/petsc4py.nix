{
  buildPythonPackage,
  fetchpatch,
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

  patches = [
    (fetchpatch {
      name = "dont-call-matsetup-if-context-is-none.patch";
      url = "https://gitlab.com/petsc/petsc/-/commit/b2584804908b6ae8fffb813f76258847e9469937.patch";
      hash = "sha256-Kd3aPoMs4yrk33Q39XECTsjydzH3ciyaji1eKvydCow=";
    })
  ];

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
