{
  lib,
  fetchFromGitHub,
  python3Packages,

  wrapGAppsHook3,
  gobject-introspection,

  atk,
  gtk-layer-shell,
  gdk-pixbuf,
  pango,
  playerctl,

  # Extra packages called by various internal nwg-panel modules
  hyprland, # hyprctl
  sway, # swaylock, swaymsg
  systemd, # systemctl
  wlr-randr, # wlr-randr
  nwg-menu, # nwg-menu
  brightnessctl, # brightnessctl
  pamixer, # pamixer
  pulseaudio, # pactl
  libdbusmenu-gtk3, # tray
}:

python3Packages.buildPythonApplication rec {
  pname = "nwg-panel";
  version = "0.10.10";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "nwg-piotr";
    repo = "nwg-panel";
    tag = "v${version}";
    hash = "sha256-fZjjfblXFyB4npcv5xKXGqnqNCAdmvJTErI+0PcuaPk=";
  };

  # No tests
  doCheck = false;

  # Because of wrapGAppsHook3
  strictDeps = false;
  dontWrapGApps = true;

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    atk
    gdk-pixbuf
    gtk-layer-shell
    libdbusmenu-gtk3 # Run-time GTK dependency required by the Tray module
    pango
    playerctl
  ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    i3ipc
    netifaces
    psutil
    pybluez
    pygobject3
    requests
    dasbus
  ];

  postInstall = ''
    install -Dm644 nwg-panel-config.desktop nwg-processes.desktop -t $out/share/applications/
    install -Dm644 nwg-shell.svg nwg-panel.svg nwg-processes.svg -t $out/share/pixmaps/
  '';

  preFixup = ''
    makeWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
      --prefix XDG_DATA_DIRS : "$out/share"
      --prefix PATH : "${
        lib.makeBinPath [
          brightnessctl
          hyprland
          nwg-menu
          pamixer
          pulseaudio
          sway
          systemd
          wlr-randr
        ]
      }"
    )
  '';

  meta = {
    homepage = "https://github.com/nwg-piotr/nwg-panel";
    changelog = "https://github.com/nwg-piotr/nwg-panel/releases/tag/${src.tag}";
    description = "GTK3-based panel for Sway window manager";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ ludovicopiero ];
    mainProgram = "nwg-panel";
  };
}
