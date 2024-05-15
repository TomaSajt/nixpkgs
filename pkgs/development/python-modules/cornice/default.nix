{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, setuptools-scm
, pyramid
, pytestCheckHook
, pytest-cache
, webtest
, marshmallow
, colander
}:

buildPythonPackage rec {
  pname = "cornice";
  version = "6.1.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-v9G2wqmRp8yxsggrbenjuPGYtqK0oHqwgA4F3wWkU2E=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ pyramid ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cache
    webtest
    marshmallow
    colander
  ];

  pythonImportsCheck = [ "cornice" ];

  meta = with lib; {
    homepage = "https://github.com/mozilla-services/cornice";
    description = "Build Web Services with Pyramid";
    license = licenses.mpl20;
    maintainers = [ ];
  };
}
