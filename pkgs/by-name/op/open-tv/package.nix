{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  fetchNpmDeps,
  npmHooks,
  nodejs,
  cargo-tauri,
  pkg-config,

  libayatana-appindicator,
  openssl,
  webkitgtk_4_1,
}:

rustPlatform.buildRustPackage rec {
  pname = "open-tv";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "Fredolx";
    repo = "open-tv";
    rev = "v${version}";
    hash = "sha256-XB71CFr+2dPkLT8y6+kRtO1k/4Hfz4vxuN0sPyyBKMA=";
  };

  postPatch = ''
    # we don't have ng available on the path
    substituteInPlace src-tauri/tauri.conf.json \
      --replace-fail 'ng build' 'npm exec -- ng build'

    substituteInPlace $cargoDepsCopy/libappindicator-sys-*/src/lib.rs \
      --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
  '';

  cargoRoot = "src-tauri";
  buildAndTestSubdir = cargoRoot;

  useFetchCargoVendor = true;
  cargoHash = "sha256-HpbSfKf0pe8S5jPYOMv5RGG8uxYDNOHm/1+3aeK3QU8=";

  npmDeps = fetchNpmDeps {
    name = "${pname}-${version}-npm-deps";
    inherit src;
    hash = "sha256-HuV9OKX+xBcAAPeE0wq9Vn/yPvp4o2cB2G3W/npD87o=";
  };

  nativeBuildInputs = [
    npmHooks.npmConfigHook
    nodejs
    cargo-tauri.hook
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    openssl
    webkitgtk_4_1
    libayatana-appindicator
  ];

  # many tests use the network
  doCheck = false;

  meta = {
    description = "Ultra-fast, simple and powerful cross-platform IPTV app";
    homepage = "https://github.com/Fredolx/open-tv";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ tomasajt ];
    mainProgram = "open-tv";
  };
}
