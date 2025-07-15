{
  lib,
  python3,
  fetchPypi,
  wrapGAppsHook3,
  gtk3,
  librsvg,
  argyllcms,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "displaycal";
  version = "3.9.16";
  pyproject = true;

  src = fetchPypi {
    pname = "DisplayCAL";
    inherit version;
    hash = "sha256-Ozl0RrYJ/oarNddnz+JjQKyRY6ZNvM9sJapqn75X3Mw=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    gtk3
  ];

  buildInputs = [
    gtk3
    librsvg
  ];

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    build
    certifi
    dbus-python
    distro
    numpy
    pillow
    protobuf
    pychromecast
    send2trash
    wxpython
    zeroconf
  ];

  doCheck = false; # Tests try to access an X11 session and dbus in weird locations.

  pythonImportsCheck = [ "DisplayCAL" ];

  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=(
      ''${gappsWrapperArgs[@]}
      --prefix PATH : ${lib.makeBinPath [ argyllcms ]}
    )
  '';

  meta = with lib; {
    description = "Display calibration and characterization powered by Argyll CMS (Migrated to Python 3)";
    homepage = "https://github.com/eoyilmaz/displaycal-py3";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ toastal ];
  };
}
