{
  lib,
  fetchFromGitHub,
  python3Packages,
  adwaita-icon-theme,
  gtk3,
  wrapGAppsHook3,
  gtksourceview3,
  gobject-introspection,
}:

python3Packages.buildPythonApplication {
  pname = "snapper-gui";
  version = "2020-10-20";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ricardomv";
    repo = "snapper-gui";
    rev = "f0c67abe0e10cc9e2ebed400cf80ecdf763fb1d1";
    sha256 = "13j4spbi9pxg69zifzai8ifk4207sn0vwh6vjqryi0snd5sylh7h";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    adwaita-icon-theme
    gtk3
    gtksourceview3
  ];

  doCheck = false; # it doesn't have any tests

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    dbus-python
    pygobject3
    setuptools # pkg_resources is imported during runtime
    # TODO: should snapper, the CLI tool be included?
  ];

  dontWrapGApps = true;

  makeWrapperArgs = [ "\${gappsWrapperArgs[@]}" ];

  meta = with lib; {
    description = "Graphical interface for snapper";
    mainProgram = "snapper-gui";
    longDescription = ''
      A graphical user interface for the tool snapper for Linux filesystem
      snapshot management. It can compare snapshots and revert differences between snapshots.
      In simple terms, this allows root and non-root users to view older versions of files
      and revert changes. Currently works with btrfs, ext4 and thin-provisioned LVM volumes.
    '';
    homepage = "https://github.com/ricardomv/snapper-gui";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ahuzik ];
  };
}
