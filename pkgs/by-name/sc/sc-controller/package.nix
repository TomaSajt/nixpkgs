{
  lib,
  python3Packages,
  fetchFromGitHub,
  wrapGAppsHook3,
  gtk3,
  gobject-introspection,
  libappindicator-gtk3,
  librsvg,
  bluez,
  linuxHeaders,
  libX11,
  libXext,
  libXfixes,
  libusb1,
  udev,
  udevCheckHook,
  gtk-layer-shell,
}:

python3Packages.buildPythonApplication rec {
  pname = "sc-controller";
  version = "0.5.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "C0rn3j";
    repo = "sc-controller";
    tag = "v${version}";
    hash = "sha256-w7jVh0d8u6csXOQ6pjUCSD3R/qFVqTa2gcGa47pqn/0=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
    udevCheckHook
  ];

  buildInputs = [
    gtk3
    libappindicator-gtk3
    librsvg
    gtk-layer-shell
  ];

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    evdev
    pygobject3
    pylibacl
    vdf
    ioctl-opt
    python3Packages.libusb1 # we need the python package here
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  patches = [ ./scc_osd_keyboard.patch ];

  postPatch = ''
    substituteInPlace scc/paths.py --replace-fail sys.prefix "'$out'"
    substituteInPlace scc/uinput.py --replace-fail /usr/include ${linuxHeaders}/include
    substituteInPlace scc/device_monitor.py --replace-fail 'find_library("bluetooth")' '"libbluetooth.so.3"'
  '';

  env.LD_LIBRARY_PATH = lib.makeLibraryPath [
    libX11
    libXext
    libXfixes
    libusb1
    udev
    bluez
  ];

  preFixup = ''
    gappsWrapperArgs+=(--prefix LD_LIBRARY_PATH : "$LD_LIBRARY_PATH")
  '';

  postFixup = ''
    (
      # scc runs these scripts as programs. (See find_binary() in scc/tools.py.)
      cd $out/lib/python*/site-packages/scc/x11
      patchPythonScript scc-autoswitch-daemon.py
      patchPythonScript scc-osd-daemon.py
    )
  '';

  doInstallCheck = true;

  meta = {
    homepage = "https://github.com/C0rn3j/sc-controller";
    # donations: https://www.patreon.com/kozec
    description = "User-mode driver and GUI for Steam Controller and other controllers";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [
      orivej
      rnhmjoj
    ];
  };
}
