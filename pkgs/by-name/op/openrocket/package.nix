{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gradle_8,
  makeWrapper,
  jre,
}:

let
  gradle = gradle_8;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "openrocket";
  version = "24.12";

  src = fetchFromGitHub {
    owner = "openrocket";
    repo = "openrocket";
    rev = "release-${finalAttrs.version}";
    hash = "sha256-Vb1NkhEkMvotyGzswq3Lq0RbG1rTmtfzRD+MHbsYFWM=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace swing/build.gradle \
      --replace-fail "implementation(project(path: ':core', configuration: 'default'))" "// @core@"
  '';

  /*preConfigure = ''
    substituteInPlace swing/build.gradle \
      --replace-fail "// @core@" "implementation(project(path: ':core', configuration: 'default'))"
  '';*/

  nativeBuildInputs = [
    gradle
    makeWrapper
  ];

  # if the package has dependencies, mitmCache must be set
  mitmCache = gradle.fetchDeps {
    inherit (finalAttrs) pname;
    data = ./deps.json;
  };

  gradleBuildTask = ":core";

  # this is required for using mitm-cache on Darwin
  __darwinAllowLocalNetworking = true;

  installPhase = ''
    runHook preInstall

    find -name "*.jar"

    #sed -i "s|Icon=.*|Icon=openrocket|g" snap/gui/openrocket.desktop
    #install -Dm644 snap/gui/openrocket.desktop -t $out/share/applications
    #install -Dm644 snap/gui/openrocket.png -t $out/share/icons/hicolor/256x256/apps
    #install -Dm644 swing/build/jar/OpenRocket.jar -t $out/share/openrocket

    makeWrapper ${lib.getExe jre} $out/bin/openrocket \
      --add-flags "-jar $out/share/openrocket/OpenRocket.jar"

    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/openrocket/openrocket/releases/tag/${finalAttrs.src.rev}";
    description = "Model-rocketry aerodynamics and trajectory simulation software";
    homepage = "https://openrocket.info";
    license = lib.licenses.gpl3Plus;
    mainProgram = "openrocket";
    maintainers = with lib.maintainers; [ tomasajt ];
    platforms = jre.meta.platforms;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # source bundles dependencies as jars
    ];
  };
})
