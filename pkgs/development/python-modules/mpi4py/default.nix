{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  pytestCheckHook,
  mpi,
  mpiCheckPhaseHook,
  openssh,
}:

buildPythonPackage rec {
  pname = "mpi4py";
  version = "3.1.6";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-yPpiXg+SsILvlVv7UvGfpmkdKSc9fXETXSlaoUPe5ss=";
  };

  postPatch = ''
    substituteInPlace test/test_spawn.py --replace-fail \
                      "unittest.skipMPI('openmpi(<3.0.0)')" \
                      "unittest.skipMPI('openmpi')"
  '';

  build-system = [ setuptools ];

  nativeBuildInputs = [ mpi ];

  __darwinAllowLocalNetworking = true;

  nativeCheckInputs = [
    pytestCheckHook
    mpiCheckPhaseHook
    openssh
  ];

  disabledTests = [
    "testFree"
    "testCommSelfSetErrhandler"
    "testCommWorldSetErrhandler"
  ];

  passthru = {
    inherit mpi;
  };

  meta = {
    description = "Python bindings for the Message Passing Interface standard";
    homepage = "https://github.com/mpi4py/mpi4py";
    license = lib.licenses.bsd2;
    maintainer = with lib.maintainers; [ tomasajt ];
  };
}
