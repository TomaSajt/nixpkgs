{
  lib,
  python3,
  fetchPypi,
  copyDesktopItems,
  makeDesktopItem,
  qt6,
}:

let
  # get rid of rec
  pname = "pyspread";
  version = "2.4";
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-MZlR2Rap5oMRfCmswg9W//FYFkSEki7eyMNhLoGZgJM=";
  };
in
python3.pkgs.buildPythonApplication {
  inherit pname version src;
  pyproject = true;

  nativeBuildInputs = [
    copyDesktopItems
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
  ];

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    numpy
    pyqt6
    markdown2
    setuptools # pkg_resources is imported during runtime

    # optional deps:
    matplotlib
    pyenchant
    python-dateutil
    # py-moneyed
    rpy2
    plotnine
    # pycel
    openpyxl
  ];

  doCheck = false; # it fails miserably with a core dump

  pythonImportsCheck = [ "pyspread" ];

  desktopItems = [
    (makeDesktopItem {
      name = "pyspread";
      exec = "pyspread";
      icon = "pyspread";
      desktopName = "Pyspread";
      genericName = "Spreadsheet";
      comment = "A Python-oriented spreadsheet application";
      categories = [
        "Office"
        "Development"
        "Spreadsheet"
      ];
    })
  ];

  dontWrapQtApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  meta = {
    homepage = "https://pyspread.gitlab.io/";
    description = "Python-oriented spreadsheet application";
    longDescription = ''
      pyspread is a non-traditional spreadsheet application that is based on and
      written in the programming language Python. The goal of pyspread is to be
      the most pythonic spreadsheet.

      pyspread expects Python expressions in its grid cells, which makes a
      spreadsheet specific language obsolete. Each cell returns a Python object
      that can be accessed from other cells. These objects can represent
      anything including lists or matrices.
    '';
    license = with lib.licenses; [ gpl3Plus ];
    mainProgram = "pyspread";
    maintainers = with lib.maintainers; [ ];
  };
}
