{
  lib,
  stdenv,
  fetchFromGitHub,
  importDubLock,
  dubSetupHook,
  dubBuildHook,
  ldc,
}:

stdenv.mkDerivation rec {
  pname = "literate";
  version = "0-unstable-2021-01-22";

  src = fetchFromGitHub {
    owner = "zyedidia";
    repo = "Literate";
    rev = "7004dffec0cff3068828514eca72172274fd3f7d";
    hash = "sha256-erNFe0+FlrslEENyO/YxYQbmec0voK31UWr5qVt+nXQ=";
    fetchSubmodules = true;
  };

  dubDeps = importDubLock {
    inherit pname version;
    lock = ./dub-lock.json; # empty lockfile
  };

  nativeBuildInputs = [
    dubSetupHook
    dubBuildHook
    ldc
  ];

  # generate the actual .d source files defined in .lit files
  preBuild = ''
    make d-files
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/lit -t $out/bin
    runHook postInstall
  '';

  meta = {
    description = "Literate programming tool for any language";
    homepage = "https://zyedidia.github.io/literate/";
    license = lib.licenses.mit;
    mainProgram = "lit";
    platforms = lib.platforms.unix;
  };
}
