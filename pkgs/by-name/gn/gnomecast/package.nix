{
  stdenv,
  lib,
  python3Packages,
  fetchFromGitHub,
  gtk3,
  gobject-introspection,
  ffmpeg,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication {
  pname = "gnomecast";
  version = "unstable-2022-04-23";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "keredson";
    repo = "gnomecast";
    rev = "d42d8915838b01c5cadacb322909e08ffa455d4f";
    sha256 = "sha256-CJpbBuRzEjWb8hsh3HMW4bZA7nyDAwjrERCS5uGdwn8=";
  };

  nativeBuildInputs = [ wrapGAppsHook3 ];

  buildInputs = [
    gtk3
    gobject-introspection
  ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pychromecast
    bottle
    pycaption
    paste
    html5lib
    pygobject3
    dbus-python
  ];

  # There *are* tests, but they have not been updated to work
  # with the latest version of the package
  doCheck = false;

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
  ];

  # NOTE: gdk-pixbuf setup hook does not run with strictDeps
  # https://nixos.org/manual/nixpkgs/stable/#ssec-gnome-hooks-gobject-introspection
  strictDeps = false;

  # don't double-wrap the executables
  dontWrapGApps = true;

  makeWrapperArgs = [
    "\${gappsWrapperArgs[@]}"
    "--prefix PATH : ${lib.makeBinPath [ ffmpeg ]}"
  ];

  meta = with lib; {
    description = "Native Linux GUI for Chromecasting local files";
    homepage = "https://github.com/keredson/gnomecast";
    license = with licenses; [ gpl3 ];
    broken = stdenv.hostPlatform.isDarwin;
    mainProgram = "gnomecast";
  };
}
