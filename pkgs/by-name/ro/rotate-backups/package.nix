{
  lib,
  python312Packages,
  fetchFromGitHub,
}:

let
  # executor-23.2 not supported for interpreter python3.13
  python3Packages = python312Packages;
in
python3Packages.buildPythonApplication rec {
  pname = "rotate-backups";
  version = "8.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "xolox";
    repo = "python-rotate-backups";
    rev = version;
    sha256 = "0r4dyd7hj403rksgp3vh1azp9n4af75r3wq3x39wxcqizpms3vkx";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    python-dateutil
    simpleeval
    update-dotdee
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  disabledTests = [
    # https://github.com/xolox/python-rotate-backups/issues/33
    "test_removal_command"
  ];

  meta = with lib; {
    description = "Simple command line interface for backup rotation";
    mainProgram = "rotate-backups";
    homepage = "https://github.com/xolox/python-rotate-backups";
    license = licenses.mit;
    maintainers = with maintainers; [ eyjhb ];
  };
}
