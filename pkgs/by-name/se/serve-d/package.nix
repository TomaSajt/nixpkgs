{
  lib,
  stdenv,
  fetchFromGitHub,
  dtools,
  importDubLock,
  dubSetupHook,
  dubBuildHook,
  dubCheckHook,
  dub,
  ldc,
}:

stdenv.mkDerivation rec {
  pname = "serve-d";
  version = "0.7.6";

  src = fetchFromGitHub {
    owner = "Pure-D";
    repo = "serve-d";
    rev = "v${version}";
    hash = "sha256-h4zsW8phGcI4z0uMCIovM9cJ6hKdk8rLb/Jp4X4dkpk=";
  };

  dubDeps = importDubLock {
    inherit pname version;
    lock = ./dub-lock.json;
  };

  nativeBuildInputs = [
    dtools
    dubSetupHook
    dubBuildHook
    ldc
  ];

  doCheck = true;

  nativeCheckInputs = [
    dubCheckHook
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 serve-d -t $out/bin
    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/Pure-D/serve-d/releases/tag/${src.rev}";
    description = "D LSP server (dlang language server protocol server)";
    homepage = "https://github.com/Pure-D/serve-d";
    license = lib.licenses.mit;
    mainProgram = "serve-d";
    maintainers = with lib.maintainers; [ tomasajt ];
  };
}
