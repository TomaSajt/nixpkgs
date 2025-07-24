{
  lib,
  fetchFromGitHub,
  python3Packages,
  faad2,
  ffmpeg,
  flac,
  lame,
  vorbis-tools,
}:

python3Packages.buildPythonApplication rec {
  pname = "dr14_tmeter";
  version = "1.0.16";
  pyproject = true;

  disabled = !python3Packages.isPy3k;

  src = fetchFromGitHub {
    owner = "simon-r";
    repo = "dr14_t.meter";
    rev = "v${version}";
    sha256 = "1nfsasi7kx0myxkahbd7rz8796mcf5nsadrsjjpx2kgaaw5nkv1m";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    numpy
  ];

  makeWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        faad2
        ffmpeg
        flac
        lame
        vorbis-tools
      ]
    }"
  ];

  # There are no tests
  doCheck = false;

  pythonImportsCheck = [ "dr14tmeter.dr14_tmeter" ];

  meta = with lib; {
    description = "Compute the DR14 of a given audio file according to the procedure described by the Pleasurize Music Foundation";
    mainProgram = "dr14_tmeter";
    license = licenses.gpl3Plus;
    homepage = "http://dr14tmeter.sourceforge.net/";
    maintainers = [ ];
  };
}
