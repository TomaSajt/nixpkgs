{
  lib,
  fetchFromGitLab,
  python3Packages,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk3,
  wrapGAppsHook3,
  xrandr,
}:

python3Packages.buildPythonApplication rec {
  pname = "arandr";
  version = "0.1.11";
  pyproject = true;

  src = fetchFromGitLab {
    owner = "arandr";
    repo = "arandr";
    tag = version;
    hash = "sha256-nQtfOKAnWKsy2DmvtRGJa4+Y9uGgX41BeHpd9m4d9YA=";
  };

  # patch to set mtime=0 on setup.py
  patches = [ ./gzip-timestamp-fix.patch ];
  patchFlags = [ "-p0" ];

  preBuild = ''
    rm -rf data/po/*
  '';

  # no tests
  doCheck = false;

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    gsettings-desktop-schemas
    gtk3
  ];

  build-system = with python3Packages; [
    setuptools
    docutils
  ];

  dependencies = with python3Packages; [
    pygobject3
  ];

  # don't double-wrap the executables
  dontWrapGApps = true;

  makeWrapperArgs = [
    "\${gappsWrapperArgs[@]}"
    "--prefix PATH : ${lib.makeBinPath [ xrandr ]}"
  ];

  meta = with lib; {
    homepage = "https://christian.amsuess.com/tools/arandr/";
    description = "Simple visual front end for XRandR";
    license = licenses.gpl3;
    maintainers = with maintainers; [ gepbird ];
    mainProgram = "arandr";
  };
}
