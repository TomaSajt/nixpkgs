{ lib
, stdenv
, fetchgit
, ant
, jdk
, makeWrapper
, canonicalize-jars-hook
, jre
, coreutils
, which
}:

stdenv.mkDerivation {
  pname = "projectlibre";
  version = "1.7.0";

  src = fetchgit {
    url = "https://git.code.sf.net/p/projectlibre/code";
    rev = "0c939507cc63e9eaeb855437189cdec79e9386c2"; # version 1.7.0 was not tagged
    hash = "sha256-eLUbsQkYuVQxt4px62hzfdUNg2zCL/VOSVEVctfbxW8=";
  };

  nativeBuildInputs = [
    ant
    jdk
    makeWrapper
    canonicalize-jars-hook # overlapped files, manifest creation date
    # THIS MESSES UP THE CLASSPATH, BECAUSE OF LINEBREAKS
  ];

  buildPhase = ''
    export ANT_OPTS=-Dbuild.sysclasspath=ignore
    ant -f openproj_build/build.xml
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/{projectlibre/samples,doc/projectlibre}
    resourcesPath=openproj_build/resources

    cp -R openproj_build/dist/* $out/share/projectlibre
    cp -R openproj_build/license $out/share/doc/projectlibre
    cp -R $resourcesPath/samples/* $out/share/projectlibre/samples
    install -Dm644 $resourcesPath/projectlibre.desktop -t $out/share/applications
    install -Dm644 $resourcesPath/projectlibre.png -t $out/share/pixmaps
    install -Dm755 $resourcesPath/projectlibre -t $out/bin

    substituteInPlace $out/bin/projectlibre \
        --replace "\"/usr/share/projectlibre\"" "\"$out/share/projectlibre\""

    wrapProgram $out/bin/projectlibre \
        --prefix PATH : ${lib.makeBinPath [ jre coreutils which ]}

    runHook postInstall
  '';

  meta = {
    description = "Project-Management Software similar to MS-Project";
    homepage = "https://www.projectlibre.com/";
    license = lib.licenses.cpal10;
    mainProgram = "projectlibre";
    maintainers = with lib.maintainers; [ Mogria tomasajt ];
  };
}
