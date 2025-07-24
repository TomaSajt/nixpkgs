{
  lib,
  fetchFromGitHub,
  atk,
  gdk-pixbuf,
  gobject-introspection,
  gtk-layer-shell,
  gtk3,
  pango,
  python3Packages,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication rec {
  pname = "nwg-displays";
  version = "0.3.25";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "nwg-piotr";
    repo = "nwg-displays";
    tag = "v${version}";
    hash = "sha256-Om5kz3mtrQPd5aHZwf/9BBDnPfSzMhyRp05MqX+7XzQ=";
  };

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    atk
    gtk3
    gdk-pixbuf
    gtk-layer-shell
    pango
  ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    gst-python
    i3ipc
    pygobject3
  ];

  dontWrapGApps = true;

  postInstall = ''
    install -Dm444 nwg-displays.svg -t $out/share/icons/hicolor/scalable/apps
    install -Dm444 nwg-displays.desktop -t $out/share/applications
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}");
  '';

  # Upstream has no tests
  doCheck = false;

  meta = {
    homepage = "https://github.com/nwg-piotr/nwg-displays";
    description = "Output management utility for Sway and Hyprland";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ qf0xb ];
    mainProgram = "nwg-displays";
  };
}
