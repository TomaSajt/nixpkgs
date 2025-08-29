{
  lib,
  stdenv,
  fetchFromGitHub,
  importDubLock,
  dubSetupHook,
  dubBuildHook,
  ldc,
  clang,
  which,
}:

stdenv.mkDerivation rec {
  pname = "dstep";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "jacob-carlborg";
    repo = "dstep";
    rev = "v${version}";
    hash = "sha256-ZFz2+GtBk3StqXo/9x47xrDFdz5XujHR62hj0p3AjcY=";
  };

  dubDeps = importDubLock {
    inherit pname version;
    lock = ./dub-lock.json;
  };

  nativeBuildInputs = [
    dubSetupHook
    dubBuildHook
    ldc
    which
    clang
  ];

  configurePhase = ''
    runHook preConfigure
    ldc2 -run configure.d --llvm-path=${lib.getLib clang.cc}
    runHook postConfigure
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/dstep -t $out/bin
    runHook postInstall
  '';

  meta = with lib; {
    description = "Tool for converting C and Objective-C headers to D modules";
    homepage = "https://github.com/jacob-carlborg/dstep";
    license = licenses.boost;
    mainProgram = "dstep";
    maintainers = with maintainers; [ imrying ];
  };
}
