{
  lib,
  buildNpmPackage,
  rustPlatform,
  fetchFromGitHub,

  cargo,
  rustc,
}:

buildNpmPackage (finalAttrs: {
  pname = "query-process";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "Zagrios";
    repo = "query-process";
    rev = "v${finalAttrs.version}";
    hash = "sha256-x+JB5bRgSjkDPs+35YRjI00h2yW2WjsxIe2p+SZ2HXQ=";
  };

  patches = [
    ./add-cargo-lock.patch
    ./add-missing-npm-integrity-hashes.patch
  ];

  npmDepsHash = "sha256-awvhMDhH5q/eroCm2QzcgKQkSUZx5jRKFRB1qX6sP1A=";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs)
      pname
      version
      src
      patches
      ;
    hash = "sha256-dNFCKyftWCXkI/Dq95ZUP9ZIkY+nUSZay3wp5XF/aSw=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  postInstall = ''
    install -Dm755 ./*.node -t $out/lib/node_modules/query-process
  '';

  meta = {
    description = "Native Node.js npm library designed for querying information about external processes";
    homepage = "https://github.com/Zagrios/query-process";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})
