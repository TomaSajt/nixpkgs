# Heavily based on
# https://github.com/risicle/nix-heuristic-gc/blob/0.6.0/default.nix
{
  lib,
  fetchFromGitHub,
  nixVersions,
  boost,
  python3Packages,
}:

let
  nix = nixVersions.nix_2_24;
in
python3Packages.buildPythonPackage rec {
  pname = "nix-heuristic-gc";
  version = "0.6.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "risicle";
    repo = "nix-heuristic-gc";
    tag = "v${version}";
    hash = "sha256-3SSIbfOx6oYsCZgK71bbx2H3bAMZ3VJxWfiMVPq5FaE=";
  };

  patches = [ ./a.patch ];

  # NIX_SYSTEM suggested at
  # https://github.com/NixOS/nixpkgs/issues/386184#issuecomment-2692433531
  env.NIX_SYSTEM = nix.stdenv.hostPlatform.system;
  env.NIX_CFLAGS_COMPILE = "-I${lib.getDev nix}/include/nix";

  build-system = with python3Packages; [
    pybind11
    setuptools
  ];

  buildInputs = [
    boost
    nix
  ];

  dependencies = with python3Packages; [
    humanfriendly
    rustworkx
  ];

  nativecheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  preCheck = ''
    mv nix_heuristic_gc .nix_heuristic_gc
  '';

  meta = {
    mainProgram = "nix-heuristic-gc";
    description = "Discerning garbage collection for Nix";
    longDescription = ''
      A more discerning cousin of `nix-collect-garbage`, mostly intended as a
      testbed to allow experimentation with more advanced selection processes.
    '';
    homepage = "https://github.com/risicle/nix-heuristic-gc";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [
      ris
      me-and
    ];
  };
}
