python:

{
  some-python-package = python.mkPythonPackage (import ./python-packages/some-python-package.nix);
  another-python-package = python.mkPythonPackage (import ./python-packages/another-python-package.nix);
}
