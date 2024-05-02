{
  lib,
  buildPythonPackage,
  fetchFromGitea,
  flit-core,
  pytestCheckHook,
  nose,
}:

buildPythonPackage rec {
  pname = "pylit";
  version = "0.8.0";
  pyproject = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "milde";
    repo = "pylit";
    rev = version;
    hash = "sha256-kXiWRRccv3ZI0v6efJRLYJ2Swx60W3QUtM1AEF6IMpo=";
  };

  build-system = [ flit-core ];

  nativeCheckInputs = [
    #pytestCheckHook
    #nose
  ];

  pythonImportsCheck = [ "pylit" ];

  meta = {
    maintainers = with lib.maintainers; [ tomasajt ];
  };
}
