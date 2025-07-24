{
  lib,
  fetchFromGitHub,
  python3,
  imagemagick,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "noteshrink";
  version = "0.1.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mzucker";
    repo = "noteshrink";
    rev = version;
    sha256 = "0xhrvg3d8ffnbbizsrfppcd2y98znvkgxjdmvbvin458m2rwccka";
  };

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    numpy
    scipy
    pillow
  ];

  makeWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ imagemagick ]}"
  ];

  pythonImportsCheck = [ "noteshrink" ];

  meta = with lib; {
    description = "Convert scans of handwritten notes to beautiful, compact PDFs";
    homepage = "https://mzucker.github.io/2016/09/20/noteshrink.html";
    license = licenses.mit;
    maintainers = with maintainers; [ rnhmjoj ];
    mainProgram = "noteshrink";
  };
}
