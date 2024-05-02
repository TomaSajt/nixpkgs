{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  numpy,
  ufl,
  fiat,
  finat,
  loopy,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "tsfc";
  version = "20240312.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "tsfc";
    rev = "Firedrake_${version}";
    hash = "sha256-ddgCqnADDns6HQmGiM48hyXsvHQSpaGF9FitXEN2/GM=";
  };

  build-system = [ setuptools ];

  dependencies = [
    numpy
    ufl
    fiat
    finat
    loopy
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  nativeCheckInputs = [ pytestCheckHook ];
}
