{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  protobuf,
  bzip2,
  rust-jemalloc-sys,
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
    protobuf
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    bzip2
    rust-jemalloc-sys
    zstd
  ];

  env = {
    # the build process invokes git if this is not set
    GIT_REVISION = "${finalAttrs.src.tag}-nixpkgs";
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  # without the checks, th build takes  up around 60G of space
  # with checks, it's more than double that
  doCheck = false;

  meta = {
    description = "Sui, a next-generation smart contract platform with high throughput, low latency, and an asset-oriented programming model powered by the Move programming language";
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
