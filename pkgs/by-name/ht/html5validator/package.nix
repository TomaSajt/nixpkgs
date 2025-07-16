{
  lib,
  fetchFromGitHub,
  jdk,
  python3,
  addBinToPathHook,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "html5validator";
  version = "0.4.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "svenkreiss";
    repo = "html5validator";
    tag = "v${version}";
    hash = "sha256-yvclqE4+2R9q/UJU9W95U1/xVJeNj+5eKvT6VQel9k8=";
  };

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    pyyaml
  ];

  makeWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ jdk ]}"
  ];

  nativeCheckInputs = [
    python3.pkgs.hacking
    python3.pkgs.pytestCheckHook
    addBinToPathHook
  ];

  meta = {
    description = "Command line tool that tests files for HTML5 validity";
    mainProgram = "html5validator";
    homepage = "https://github.com/svenkreiss/html5validator";
    changelog = "https://github.com/svenkreiss/html5validator/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ phunehehe ];
  };
}
