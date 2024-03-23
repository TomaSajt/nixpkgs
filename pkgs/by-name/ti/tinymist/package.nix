{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "tinymist";
  version = "0.11.0-unstable-2024-03-23";

  src = fetchFromGitHub {
    owner = "Myriad-Dreamin";
    repo = pname;
    rev = "b6dd6671c351554b4419642d97d9e0c8fd3b369e";
    hash = "sha256-Jqcb+70AJPlmydNHZeTGRdhJikp6VdMXAgmfVculZ24=";
    fetchSubmodules = true;
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "typst-0.11.0" = "sha256-UzZ0tbC6Dhn178GQDyLl70WTp3h5WdaBCsEKgLisZ2M=";
    };
  };

  meta = with lib; {
    description = "Tinymist is an integrated language service for Typst";
    homepage = "https://github.com/Myriad-Dreamin/tinymist";
    license = licenses.asl20;
    maintainers = [ ];
  };
}
