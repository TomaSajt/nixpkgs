{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  numpy,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "checkpoint-schedules";
  version = "1.0.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "checkpoint_schedules";
    rev = "v${version}";
    hash = "sha256-yiuUvK0BwulMBKgBZBpdjHOZk50IzSuoxsOMFoIVuWI=";
  };

  build-system = [ setuptools ];

  dependencies = [ numpy ];

  optional-dependencies = {

  };

  nativeCheckInputs = [ pytestCheckHook ];
}
