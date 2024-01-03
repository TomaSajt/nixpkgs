{ lib
, stdenv
, maven
, fetchFromGitHub
, makeWrapper
, wrapGAppsHook
, jdk
}:

let
  platformName = {
    "x86_64-linux" = "linux-x86-64";
    "aarch64-linux" = "linux-aarch64";
    "x86_64-darwin" = "darwin-x86-64";
    "aarch64-darwin" = "darwin-aarch64";
  }.${stdenv.system} or null;
in
maven.buildMavenPackage rec {
  pname = "jugglinglab";
  version = "1.6.5";

  src = fetchFromGitHub {
    owner = "jkboyce";
    repo = "jugglinglab";
    rev = "v${version}";
    hash = "sha256-Y87uHFpVs4A/wErNO2ZF6Su0v4LEvaE9nIysrqFoY8w=";
  };

  patches = [ ./make-deterministic.patch ];

  mvnHash = "sha256-1Uzo9nRw+YR/sd7CC9MTPe/lttkRX6BtmcsHaagP1Do=";

  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook
  ];

  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 bin/JugglingLab.jar -t $out/share/java
    ${lib.optionalString (platformName != null) ''
      mkdir -p $out/lib
      cp -r bin/ortools-lib/ortools-${platformName} $out/lib/ortools-lib
    ''}

    runHook postInstall
  '';

  # gappsWrapperArgs are set in preFixup
  postFixup = ''
    makeWrapper ${jdk}/bin/java $out/bin/jugglinglab \
        "''${gappsWrapperArgs[@]}" \
        --add-flags "-Xss2048k -Djava.library.path=$out/lib/ortools-lib" \
        --add-flags "-jar $out/share/java/JugglingLab.jar"
  '';

  meta = {
    description = "A program to visualize different juggling pattens";
    homepage = "https://jugglinglab.org/";
    license = lib.licenses.gpl2Only;
    mainProgram = "jugglinglab";
    maintainers = with lib.maintainers; [ wnklmnn tomasajt ];
    platforms = lib.platforms.all;
  };
}
