{
  lib,
  buildPythonPackage,
  substituteAll,
  fetchFromGitHub,
  setuptools,
  numpy,
  recursivenodes,
  scipy,
  sympy,
  pytestCheckHook,
}:

let
  fiat-reference-data = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "fiat-reference-data";
    rev = "4ef30a07a9a503d8d2b0e49efa9cd2354a9eb1bc";
    hash = "sha256-u/HZ16RsiBA3gXfoYvNsTHIhUHkfzH/SFPkEPvbpSZw=";
  };
in
buildPythonPackage rec {
  pname = "fiat";
  version = "20240312.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "fiat";
    rev = "Firedrake_${version}";
    hash = "sha256-17eVCMFTlH2s02RmvTqs49+JdCrd75/Opdm+HD1n5N4=";
  };

  patches = [
    (substituteAll {
      src = ./fiat-set-version.patch;
      inherit version;
    })
  ];

  postConfigure = ''
    cp -r --no-preserve=all ${fiat-reference-data} test/regression/fiat-reference-data
  '';

  build-system = [ setuptools ];

  dependencies = [
    numpy
    recursivenodes
    scipy
    sympy
  ];

  pytestFlagsArray = [ "--skip-download" ];

  disabledTests = [ "test_quadrature" ];

  nativeCheckInputs = [ pytestCheckHook ];
}
