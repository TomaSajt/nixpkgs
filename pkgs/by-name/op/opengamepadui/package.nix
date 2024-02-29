{ lib
, fetchFromGitHub
, stdenv
, godot_4
, makeFontsConf
, dbus
, libevdev
, libX11
, pkg-config
}:

let
  templates = (godot_4.override { withTarget = "template_release"; }).overrideAttrs (oldAttrs: rec {
    pname = "godot_4_export_templates";

    # https://docs.godotengine.org/en/stable/contributing/development/compiling/compiling_for_linuxbsd.html#building-export-templates
    installPhase = ''
      install -Dm755 bin/godot.linuxbsd.template_release.x86_64 $out/share/godot/export_templates/${oldAttrs.version}.stable/linux_x11_64_release
    '';

    outputs = [ "out" ];
  });
in

stdenv.mkDerivation (finalAttrs: {
  pname = "opengamepadui";
  version = "0.30.2";

  src = fetchFromGitHub {
    owner = "ShadowBlip";
    repo = "OpenGamepadUI";
    rev = "v${finalAttrs.version}";
    hash = "sha256-qnurWrRBV2p4Ltxi03QKxClaRZi8cKZiCFm0hKaIi3Q=";
  };

  nativeBuildInputs = [
    pkg-config
    godot_4
  ];

  env.FONTCONFIG_FILE = makeFontsConf { fontDirectories = [ ]; };

  buildInputs = [
    stdenv.cc.cc.lib
    dbus
    libevdev
    libX11
  ];

  buildPhase = ''
    runHook preBuild

    export HOME=$(mktemp -d)
    install -Dm755 ${templates}/share/godot/export_templates/${godot_4.version}.stable/linux_x11_64_release $HOME/.local/share/godot/export_templates/4.2.1.stable/linux_release.x86_64

    # Regenerate project files
    timeout --foreground 60 godot4 --headless --editor . > /dev/null 2>&1 || echo "Finished"

    godot4 --headless --export-release "Linux/X11" .

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r rootfs/usr/* $out

    runHook postInstall
  '';

  meta = {
    homepage = "https://ohmygit.org/";
    description = "An interactive Git learning game";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ tomasajt ];
  };
})
