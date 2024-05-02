{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  numpy,
  symengine,
  sympy,
  ufl,
  fiat,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "finat";
  version = "20240312.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "FInAT";
    repo = "FInAT";
    rev = "Firedrake_${version}";
    hash = "sha256-YwF7V1ziJ/FY51tKlEA26PDebdIbg4DeOFUoVXYWUVA=";
  };

  build-system = [ setuptools ];

  dependencies = [
    numpy
    symengine
    sympy
    ufl
    fiat
  ];

  # has a circular dependency on tsfc's `gem` module, so we can't test
}
