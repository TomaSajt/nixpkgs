{
  lib,
  fetchFromGitHub,
  python3Packages,
  gobject-introspection,
  wrapGAppsNoGuiHook,
}:

python3Packages.buildPythonPackage rec {
  pname = "open-fprintd";
  version = "0.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "uunicorn";
    repo = "open-fprintd";
    rev = version;
    hash = "sha256-4TraOKvBc7ddqcY73aCuKgfwx4fNoaPHVG8so8Dc5Bw=";
  };

  nativeBuildInputs = [
    wrapGAppsNoGuiHook
    gobject-introspection
  ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    dbus-python
    pygobject3
  ];

  postInstall = ''
    substituteInPlace debian/open-fprintd*.service \
      --replace-fail "/usr/lib/open-fprintd" "$out/lib/open-fprintd"

    install -Dm644 debian/open-fprintd*.service -t $out/lib/systemd/system/
  '';

  dontWrapGApps = true;
  makeWrapperArgs = [ "\${gappsWrapperArgs[@]}" ];

  postFixup = ''
    wrapPythonProgramsIn "$out/lib/open-fprintd" "$out $pythonPath"
  '';

  meta = with lib; {
    description = "Fprintd replacement which allows you to have your own backend as a standalone service";
    homepage = "https://github.com/uunicorn/open-fprintd";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
