{
  lib,
  python3,
  fetchFromGitHub,
  awscli,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "nimbo";
  version = "0.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "nimbo-sh";
    repo = "nimbo";
    rev = "v${version}";
    hash = "sha256-YC5T02Sw22Uczufbyts8l99oCQW4lPq0gPMRXCoKsvw=";
  };

  build-system = with python3.pkgs; [ setuptools ];

  postPatch = ''
    # awscli is never imported as a python package, it's only used from PATH
    # Note: we cannot use pythonRemoveDeps because this version specifier is not spec-compliant
    substituteInPlace setup.py \
      --replace-fail "awscli>=1.19<2.0" ""
  '';

  pythonRelaxDeps = [
    "colorama"
  ];

  dependencies = with python3.pkgs; [
    setuptools # pkg_resources is imported during runtime
    boto3
    requests
    click
    pyyaml
    pydantic
    rich
    colorama
  ];

  # nimbo tests require an AWS instance
  doCheck = false;
  pythonImportsCheck = [ "nimbo" ];

  makeWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ awscli ]}"
  ];

  meta = with lib; {
    description = "Run machine learning jobs on AWS with a single command";
    homepage = "https://github.com/nimbo-sh/nimbo";
    license = licenses.bsl11;
    maintainers = with maintainers; [ noreferences ];
  };
}
