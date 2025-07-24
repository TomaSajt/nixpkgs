{
  lib,
  python3Packages,
  fetchFromGitHub,
  wrapGAppsHook3,
  p7zip,
  parted,
  grub2,
}:

python3Packages.buildPythonApplication rec {
  pname = "woeusb-ng";
  version = "0.2.12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "WoeUSB";
    repo = "WoeUSB-ng";
    rev = "v${version}";
    hash = "sha256-2opSiXbbk0zDRt6WqMh97iAt6/KhwNDopOas+OZn6TU=";
  };

  postPatch = ''
    substituteInPlace setup.py WoeUSB/*.py miscellaneous/* \
      --replace "/usr/local/" "$out/" \
      --replace "/usr/" "$out/"
  '';

  nativeBuildInputs = [
    wrapGAppsHook3
  ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    termcolor
    wxpython
    six
  ];

  preConfigure = ''
    mkdir -p $out/bin $out/share/applications $out/share/polkit-1/actions
  '';

  makeWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        p7zip
        parted
        grub2
      ]
    }"
  ];

  # Unable to access the X Display, is $DISPLAY set properly?
  doCheck = false;

  meta = with lib; {
    description = "Tool to create a Windows USB stick installer from a real Windows DVD or image";
    homepage = "https://github.com/WoeUSB/WoeUSB-ng";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ stunkymonkey ];
    platforms = platforms.linux;
  };
}
