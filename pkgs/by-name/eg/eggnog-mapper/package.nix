{
  lib,
  autoPatchelfHook,
  fetchFromGitHub,
  python3Packages,
  wget,
  zlib,
}:

python3Packages.buildPythonApplication rec {
  pname = "eggnog-mapper";
  version = "2.1.12";
  pyproject = true;
  build-system = with python3Packages; [ setuptools ];

  src = fetchFromGitHub {
    owner = "eggnogdb";
    repo = "eggnog-mapper";
    tag = version;
    hash = "sha256-+luxXQmtGufYrA/9Ak3yKzbotOj2HM3vhIoOxE+Ty1U=";
  };

  postPatch = ''
    # Not a great solution...
    substituteInPlace setup.cfg \
      --replace-fail "==" ">="
  '';

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    zlib
  ];

  dependencies = with python3Packages; [
    biopython
    psutil
    xlsxwriter
  ];

  makeWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ wget ]}"
  ];

  # Tests rely on some of the databases being available, which is not bundled
  # with this package as (1) in total, they represent >100GB of data, and (2)
  # the user can download only those that interest them.
  doCheck = false;

  meta = with lib; {
    description = "Fast genome-wide functional annotation through orthology assignment";
    license = licenses.gpl2;
    homepage = "https://github.com/eggnogdb/eggnog-mapper/wiki";
    maintainers = with maintainers; [ luispedro ];
    platforms = platforms.all;
  };
}
