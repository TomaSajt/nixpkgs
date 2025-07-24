{
  lib,
  python3Packages,
  qt6,
  fetchFromGitHub,
  copyDesktopItems,
  makeDesktopItem,
  onedrive,
  replaceVars,
}:

python3Packages.buildPythonApplication rec {
  pname = "onedrivegui";
  version = "1.1.1a";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "bpozdena";
    repo = "OneDriveGUI";
    rev = "v${version}";
    hash = "sha256-pcY1JOi74pePvkIMRuHv5mlE4F68NzuBLJTCtgjUFRw=";
  };

  patches = [
    (replaceVars ./make-installable.patch {
      inherit version;
    })
  ];

  nativeBuildInputs = [
    copyDesktopItems
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwayland
  ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pyside6
    requests
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "OneDriveGUI";
      exec = "onedrivegui";
      desktopName = "OneDriveGUI";
      comment = "OneDrive GUI Client";
      type = "Application";
      icon = "OneDriveGUI";
      terminal = false;
      categories = [ "Utility" ];
    })
  ];

  postInstall = ''
    install -Dm444 -t $out/share/icons/hicolor/48x48/apps src/resources/images/OneDriveGUI.png
  '';

  dontWrapQtApps = true;

  makeWrapperArgs = [
    "\${qtWrapperArgs[@]}"
    "--prefix PATH : ${lib.makeBinPath [ onedrive ]}"
  ];

  meta = with lib; {
    homepage = "https://github.com/bpozdena/OneDriveGUI";
    description = "Simple GUI for Linux OneDrive Client, with multi-account support";
    mainProgram = "onedrivegui";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
