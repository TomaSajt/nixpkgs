{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cgal,
  cmake,
  gpp,
  mpfr,
  qt6Packages,
}:

stdenv.mkDerivation rec {
  pname = "valeronoi";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "ccoors";
    repo = pname;
    tag = "v${version}";
    sha256 = "sha256-5KXVSIqWDkXnpO+qgBzFtbJb444RW8dIVXp8Y/aAOrk=";
  };

  buildInputs = [
    boost
    cgal
    gpp
    mpfr
    qt6Packages.qtbase
    qt6Packages.qtimageformats
    qt6Packages.qtsvg
  ];

  nativeBuildInputs = [
    cmake
    qt6Packages.wrapQtAppsHook
  ];

  doCheck = true;

  meta = with lib; {
    homepage = "https://github.com/ccoors/Valeronoi/";
    description = "WiFi mapping companion app for Valetudo";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [
      nova-madeline
      maeve
    ];
    mainProgram = "valeronoi";
  };
}
