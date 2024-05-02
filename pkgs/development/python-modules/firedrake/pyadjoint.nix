{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  scipy,
  six,
  checkpoint-schedules,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pyadjoint";
  version = "2023.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "dolfin-adjoint";
    repo = "pyadjoint";
    rev = version;
    hash = "sha256-SpqQqzpdZzJ51GHXV6wdtYmq7Kq+xLE35Rne0a1Py54=";
  };

  build-system = [ setuptools ];

  dependencies = [
    scipy
    six
    checkpoint-schedules
  ];

  # tests require fenics and firedrake
}
