{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  gramps,
  pyparsing,
}:

buildPythonPackage rec {
  pname = "object-ql";
  version = "0.1.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "dsblank";
    repo = "object-ql";
    rev = "81809e980faed7e8a5b5ba661b6b271d18408747";
    hash = "sha256-N1RucnR/QQvFf+RzSv45T5neU8QR2UN+nftZAy5LUkg=";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    gramps
    pyparsing
  ];

  pythonImportsCheck = [
    "object_ql"
  ];

  meta = {
    description = "A Python query system for querying Objects";
    homepage = "https://github.com/dsblank/object-ql";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
