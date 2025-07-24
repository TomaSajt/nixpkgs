{
  python3Packages,
  lib,
  fetchFromGitHub,
  gettext,
  gtk3,
  gobject-introspection,
  intltool,
  wrapGAppsHook3,
  glib,
  librsvg,
  libayatana-appindicator,
  libpulseaudio,
  keybinder3,
  gdk-pixbuf,
}:

python3Packages.buildPythonApplication rec {
  pname = "indicator-sound-switcher";
  version = "2.3.10.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "yktoo";
    repo = "indicator-sound-switcher";
    tag = "v${version}";
    sha256 = "sha256-Benhlhz81EgL6+pmjzyruKBOS6O7ce5PPmIIzk2Zong=";
  };

  postPatch = ''
    substituteInPlace lib/indicator_sound_switcher/lib_pulseaudio.py \
      --replace-fail "CDLL('libpulse.so.0')" "CDLL('${libpulseaudio}/lib/libpulse.so')"
  '';

  nativeBuildInputs = [
    gettext
    intltool
    wrapGAppsHook3
    glib
    gdk-pixbuf
    gobject-introspection
  ];

  buildInputs = [
    gtk3
    librsvg
    libayatana-appindicator
    keybinder3
  ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    setuptools # pkg_resources is imported during runtime
    pygobject3
  ];

  # don't double-wrap executables
  dontWrapGApps = true;

  makeWrapperArgs = [ "\${gappsWrapperArgs[@]}" ];

  pythonImportsCheck = [ "indicator_sound_switcher" ];

  meta = with lib; {
    description = "Sound input/output selector indicator for Linux";
    mainProgram = "indicator-sound-switcher";
    homepage = "https://yktoo.com/en/software/sound-switcher-indicator/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ alexnortung ];
    platforms = [ "x86_64-linux" ];
  };
}
