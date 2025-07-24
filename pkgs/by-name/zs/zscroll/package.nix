{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication rec {
  pname = "zscroll";
  version = "2.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "noctuid";
    repo = "zscroll";
    rev = version;
    sha256 = "sha256-gEluWzCbztO4N1wdFab+2xH7l9w5HqZVzp2LrdjHSRM=";
  };

  postPatch = ''
    # as of writing this, installation via pyproject.toml is not workingű
    # let's fall back to setup.py
    rm pyproject.toml
  '';

  build-system = with python3Packages; [ setuptools ];

  meta = with lib; {
    description = "Text scroller for use with panels and shells";
    mainProgram = "zscroll";
    homepage = "https://github.com/noctuid/zscroll";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
  };
}
