{
  lib,
  buildPythonPackage,
  fetchFromGitLab,
  setuptools,
  numpy,
  scipy,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "recursivenodes";
  version = "0.2.0";
  pyproject = true;

  src = fetchFromGitLab {
    owner = "tisaac";
    repo = "recursivenodes";
    rev = "v${version}";
    hash = "sha256-aYICX38uPsG80Bt2cPg5xshuTMkK1bzno5mXRkrvQbU=";
  };

  build-system = [ setuptools ];

  dependencies = [
    numpy
    scipy
  ];

  nativeCheckInputs = [ pytestCheckHook ];
}
