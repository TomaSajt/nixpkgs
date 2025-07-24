{
  lib,
  python3Packages,
  fetchFromGitHub,
  glib,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication rec {
  pname = "printrun";
  version = "2.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kliment";
    repo = "Printrun";
    tag = "printrun-${version}";
    hash = "sha256-INJNGAmghoPIiivQp6AV1XmhyIu8SjfKqL8PTpi/tkY=";
  };

  nativeBuildInputs = [
    glib
    wrapGAppsHook3
  ];

  build-system = with python3Packages; [
    setuptools
    cython
  ];

  pythonRelaxDeps = [
    "pyglet"
  ];

  dependencies = with python3Packages; [
    dbus-python
    numpy
    wxpython
    platformdirs
    psutil
    pyglet
    pyserial
    lxml
    puremagic
  ];

  postInstall = ''
    substituteInPlace $out/share/applications/*.desktop \
      --replace-fail "/usr/" "$out/"
  '';

  nativeCheckInputs = with python3Packages; [
    unittestCheckHook
  ];

  unittestFlagsArray = [
    "-s"
    "tests"
  ];

  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    description = "Pronterface, Pronsole, and Printcore - Pure Python 3d printing host software";
    homepage = "https://github.com/kliment/Printrun";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
