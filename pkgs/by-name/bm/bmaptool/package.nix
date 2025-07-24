{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "bmaptool";
  version = "3.8.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "yoctoproject";
    repo = "bmaptool";
    rev = "v${version}";
    hash = "sha256-YPY3sNuZ/TASNBPH94iqG6AuBRq5KjioKiuxAcu94+I=";
  };

  build-system = with python3Packages; [ poetry-core ];

  dependencies = with python3Packages; [
    six
    gpgme
  ];

  # tests fail only on hydra.
  doCheck = false;

  pythonImportsCheck = [ "bmaptool.CLI" ];

  meta = with lib; {
    description = "BMAP Tools";
    homepage = "https://github.com/yoctoproject/bmaptool";
    license = licenses.gpl2Only;
    maintainers = [ maintainers.dezgeg ];
    platforms = platforms.linux;
    mainProgram = "bmaptool";
  };
}
