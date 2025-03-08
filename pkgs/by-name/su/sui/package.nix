{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  protobuf,
  zstd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sui";
  version = "1.43.1";

  src = fetchFromGitHub {
    owner = "MystenLabs";
    repo = "sui";
    tag = "mainnet-v${finalAttrs.version}";
    hash = "sha256-mNljh3HupusGmfT3pXtjqUp7OZHhyWd6jNiFiKlSYpk=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-ckotvpQw3WfvJ2YXR/XKT7LamGj7kLtGwMR/qrXpmYc=";

  nativeBuildInputs = [
    pkg-config
    #protobuf
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    zstd
  ];

  env = {
    # if this is not set the build will try to invoke git to get the rev
    GIT_REVISION = "nixpkgs@${finalAttrs.version}";
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  # the build takes up more than 60G of space even without the checks
  # my system ran out of space (150G) when having tests enabled
  doCheck = false;

  meta = {
    description = "Next-generation smart contract platform with high throughput, low latency, and an asset-oriented programming model powered by the Move programming language";
    homepage = "https://github.com/MystenLabs/sui";
    changelog = "https://github.com/MystenLabs/sui/blob/${finalAttrs.src.rev}/RELEASES.md";
    license = with lib.licenses; [
      cc-by-40
      asl20
    ];
    maintainers = with lib.maintainers; [ ];
    mainProgram = "sui";
  };
})
