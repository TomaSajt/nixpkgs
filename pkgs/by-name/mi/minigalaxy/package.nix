{
  lib,
  fetchFromGitHub,
  glibcLocales,
  glib-networking,
  gobject-introspection,
  gtk3,
  libnotify,
  python3Packages,
  steam-run,
  replaceVars,
  unzip,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication rec {
  pname = "minigalaxy";
  version = "1.3.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "sharkwouter";
    repo = "minigalaxy";
    tag = version;
    hash = "sha256-nxWJm+CkxZqRMUYQA0ZJKOb2fD1tPYXnYhy+DOnDbkQ=";
  };

  patches = [
    (replaceVars ./inject-launcher-steam-run.diff {
      steamrun = lib.getExe steam-run;
    })
  ];

  postPatch = ''
    substituteInPlace minigalaxy/installer.py \
      --replace-fail '"unzip"' "\"${lib.getExe unzip}\"" \
      --replace-fail "'unzip'" "\"${lib.getExe unzip}\""
  '';

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    glib-networking
    gtk3
    libnotify
    webkitgtk_4_1
  ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pygobject3
    requests
  ];

  nativeCheckInputs = with python3Packages; [
    glibcLocales
    pytestCheckHook
    simplejson
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = {
    homepage = "https://sharkwouter.github.io/minigalaxy/";
    changelog = "https://github.com/sharkwouter/minigalaxy/blob/${version}/CHANGELOG.md";
    downloadPage = "https://github.com/sharkwouter/minigalaxy/releases";
    description = "Simple GOG client for Linux";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
  };
}
