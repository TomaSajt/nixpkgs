{
  lib,
  fetchFromGitHub,
  python312Packages,
}:
let
  version = "0.1.3+";
in
python312Packages.buildPythonApplication {
  pname = "sl1-to-photon";
  inherit version;
  pyproject = true;

  src = fetchFromGitHub {
    owner = "cab404";
    repo = "SL1toPhoton";
    rev = "7edc6ea99818622f5d49ac7af80ddd4916b8c19f";
    hash = "sha256-ssFfjlBMi3FHosDBUA2gs71VUIBkEdPVcV3STNxmOIM=";
  };

  build-system = with python312Packages; [ setuptools ];

  dependencies = with python312Packages; [
    pyphotonfile
    pillow
    numpy
    pyside2
    shiboken2
  ];

  # use custom installPhase since there are no script entrypoints defined by upstream
  installPhase = ''
    runHook preInstall

    install -D -m 0755 SL1_to_Photon.py $out/bin/sl1-to-photon

    runHook postInstall
  '';

  meta = with lib; {
    maintainers = [ maintainers.cab404 ];
    license = licenses.gpl3Plus;
    description = "Tool for converting Slic3r PE's SL1 files to Photon files for the Anycubic Photon 3D-Printer";
    homepage = "https://github.com/cab404/SL1toPhoton";
    mainProgram = "sl1-to-photon";
  };

}
