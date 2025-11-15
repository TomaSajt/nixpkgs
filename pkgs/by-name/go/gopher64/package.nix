{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  cargo,
  llvmPackages,

  bzip2,
  libGL,
  libX11,
  libXcursor,
  libxkbcommon,
  libXi,
  moltenvk,
  sdl3,
  sdl3-ttf,
  wayland,
  zstd,
}:

let
  stdenv = llvmPackages.stdenv;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "gopher64";
  version = "1.1.8";

  src = fetchFromGitHub {
    owner = "gopher64";
    repo = "gopher64";
    tag = "v${finalAttrs.version}";
    fetchSubmodules = true;
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/GIT_HASH
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';

    hash = "sha256-R7cecfYc9JykgYgqDRKZsJ7H77+G5t92tVz8DUzpXMg=";
  };

  patches = [
    # upstream rebuilds SDL3 from source
    # this patch makes it use the SDL3 library provided by nixpkgs
    ./use-sdl3-via-pkg-config.patch

    # make the build script use the @GIT_HASH@ string that will be substituted in the logic below
    ./set-git-hash.patch
  ];

  postPatch = ''
    # use the file generated in the fetcher to supply the git hash
    substituteInPlace build.rs \
      --replace-fail "@GIT_HASH@" $(cat GIT_HASH)
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs)
      pname
      version
      src
      patches
      ;
    hash = "sha256-CXwAcrMHxMnVMHaqlXCkZ2r2aTonCqlruptUmCNouNs=";
  };

  env.ZSTD_SYS_USE_PKG_CONFIG = true;

  stictDeps = true;

  nativeBuildInputs = [
    pkg-config
    cargo
    rustPlatform.cargoSetupHook
    rustPlatform.bindgenHook
    llvmPackages.lld
    llvmPackages.bintools
  ];

  buildInputs = [
    bzip2
    sdl3
    sdl3-ttf
    zstd
    wayland
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    moltenvk
  ];

  buildPhase = ''
  runHook preBuild

    llvm-ar --help
    llvm-ranlib --help

    echo 'RANLIB = "llvm-ranlib"' >> .cargo/config.toml
    cargo build -j "$NIX_BUILD_CORES" --offline --profile release

    runHook postBuild
  '';

  # these are dlopen-ed during runtime
  runtimeDependencies = lib.optionalString stdenv.hostPlatform.isLinux [
    cargo

    #libGL
    #libxkbcommon

    # for X11
    #libX11
    #libXcursor
    #libXi

    # for wayland
    #wayland
  ];

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf $out/bin/gopher64 --add-rpath ${lib.makeLibraryPath finalAttrs.runtimeDependencies}
  '';

  meta = {
    changelog = "https://github.com/gopher64/gopher64/releases/tag/${finalAttrs.src.tag}";
    description = "N64 emulator written in Rust";
    homepage = "https://github.com/gopher64/gopher64";
    license = lib.licenses.gpl3Only;
    mainProgram = "gopher64";
    maintainers = with lib.maintainers; [ tomasajt ];
  };
})
