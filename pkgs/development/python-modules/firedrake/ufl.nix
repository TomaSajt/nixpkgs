{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  numpy,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "ufl";
  version = "20240312.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "ufl";
    rev = "Firedrake_${version}";
    hash = "sha256-abxk1hD1SO1PfzrqLCYd2lbHiZE+7ahOzIau3OW95U4=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
        --replace-fail ', "pip>=22.3"' ""
  '';

  build-system = [ setuptools ];

  dependencies = [ numpy ];

  nativeCheckInputs = [ pytestCheckHook ];
}
