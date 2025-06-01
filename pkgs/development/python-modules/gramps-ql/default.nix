{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  setuptools-scm,
  gramps,
  pyparsing,
}:

buildPythonPackage rec {
  pname = "gramps-ql";
  version = "0.4.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "DavidMStraub";
    repo = "gramps-ql";
    rev = "v${version}";
    hash = "sha256-PdPkvZnEoe3xUt3xFmBu7cZEt609mNcADzpTHQ5jDtA=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    gramps
    pyparsing
  ];

  pythonImportsCheck = [
    "gramps_ql"
  ];

  meta = {
    description = "GQL - the Gramps Query Language";
    homepage = "https://github.com/DavidMStraub/gramps-ql";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
