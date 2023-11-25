{ lib
, buildGoModule
, fetchFromGitHub
, pkg-config
, wrapGAppsHook
, wireguard-tools
, gtk3
, libayatana-appindicator
}:

buildGoModule rec {
  pname = "wireguird";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "UnnoTed";
    repo = "wireguird";
    rev = "v${version}";
    hash = "sha256-iv0/HSu/6IOVmRZcyCazLdJyyBsu5PyTajLubk0speI=";
  };

  patches = [
    # Without this we'd get errors, like `vendor/golang.org/x/sys/unix/syscall.go:83:16: unsafe.Slice requires go1.17 or later (-lang was set to go1.16; check go.mod)`
    # To generate this patch, run `go mod tidy`, then change the go version to 1.17 inside `go.mod`, then run `go mod tidy again`
    ./fix-go-version-error.patch
    ./remove-hardcoded-paths.patch
  ];

  postPatch = ''
    substituteInPlace \
        wireguird.glade main.go gui/gui.go deb/usr/share/applications/wireguird.desktop deb/usr/share/polkit-1/actions/wireguird.policy \
        --subst-var-by icon_path $out/Icon \
        --subst-var out
  '';

  vendorHash = "sha256-NTJ0J4d7XKrSQtfHgR3bORS119AihWOffFPFZZYD1e4=";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook
  ];

  buildInputs = [
    gtk3
    wireguard-tools
    libayatana-appindicator
  ];

  postInstall = ''
    cp -r Icon $out/Icon
    cp -r deb/usr/share $out/share
  '';

  meta = {
    maintainers = with lib.maintainers; [ tomasajt ];
  };
}
