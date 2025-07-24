{
  lib,
  fetchFromGitLab,
  python3Packages,
  ffmpeg,
  mplayer,
  vcdimager,
  cdrkit,
  dvdauthor,
  gtk3,
  gettext,
  wrapGAppsHook3,
  gdk-pixbuf,
  gobject-introspection,
  nix-update-script,
}:

python3Packages.buildPythonApplication rec {
  pname = "devede";
  version = "4.21.0";
  pyproject = true;

  src = fetchFromGitLab {
    owner = "rastersoft";
    repo = "devedeng";
    tag = version;
    hash = "sha256-sLJkIKw0ciX6spugbdO0eZ1dIkoHfuu5e/f2XwA70a0=";
  };

  postPatch = ''
    substituteInPlace src/devedeng/configuration_data.py \
      --replace-fail "/usr/share" "$out/share" \
      --replace-fail "/usr/local/share" "$out/share"
  '';

  nativeBuildInputs = [
    gettext
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    gtk3
    gdk-pixbuf
  ];

  build-system = with python3Packages; [
    setuptools
    setuptools-gettext
  ];

  dependencies = with python3Packages; [
    pygobject3
    setuptools # pkg_resources is imported during runtime
  ];

  # don't double-wrap executables
  dontWrapGApps = true;

  makeWrapperArgs = [
    "\${gappsWrapperArgs[@]}"
    "--prefix PATH : ${
      lib.makeBinPath [
        ffmpeg
        mplayer
        dvdauthor
        vcdimager
        cdrkit
      ]
    }"
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "DVD Creator for Linux";
    homepage = "https://www.rastersoft.com/programas/devede.html";
    license = licenses.gpl3;
    maintainers = [
      maintainers.bdimcheff
      maintainers.baksa
    ];
  };
}
