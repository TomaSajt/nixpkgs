{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  pytestCheckHook,
  which,
  lrzsz,
}:

buildPythonPackage rec {
  pname = "xmodem";
  version = "0.4.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "tehmaze";
    repo = "xmodem";
    rev = "refs/tags/${version}";
    hash = "sha256-kwPA/lYiv6IJSKGRuH13tBofZwp19vebwQniHK7A/i8=";
  };

  build-system = [ setuptools ];

  nativeCheckInputs = [
    pytestCheckHook
    which
    lrzsz
  ];

  meta = with lib; {
    description = "Pure python implementation of the XMODEM protocol";
    maintainers = with maintainers; [ emantor ];
    homepage = "https://github.com/tehmaze/xmodem";
    license = licenses.mit;
  };
}
