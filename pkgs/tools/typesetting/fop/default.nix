{
  lib,
  maven,
  fetchFromGitHub,
  fetchpatch,
  jre,
  makeWrapper,
}:

maven.buildMavenPackage rec {
  pname = "fop";
  version = "2.9";

  src = fetchFromGitHub {
    owner = "apache";
    repo = "xmlgraphics-fop";
    rev = "refs/tags/${lib.replaceStrings [ "." ] [ "_" ] version}";
    hash = "sha256-cTz7GKtI2ETMsxCQajLR1r6jyrLh3U4gEkOkJlCuwxU=";
  };

  patches = [
    (fetchpatch {
      name = "also-generate-core-jar.patch";
      url = "https://github.com/apache/xmlgraphics-fop/commit/fa89ae7b7a349d7f015b6eeb650a839979a8eed0.patch";
      hash = "sha256-CWQ6mKNbNlR2Rd43+O3qJ4XFmVXwOXrxNX/bYMFlEjc=";
    })
    (fetchpatch {
      name = "fix-jar-classpath.patch";
      url = "https://github.com/apache/xmlgraphics-fop/commit/699b56779e89d45ae8d8ea517bc7cee57e2f4231.patch";
      hash = "sha256-aXTu4hhOKc0vo27JZm+jNQq2AeBKtSrZ0I9mULAFOas=";
    })
  ];

  mvnHash = "sha256-VEP4vPlbbFalTtH4HMdhkmEnAo8HYPN/BgfyvyS9m10=";

  mvnParameters = "-Dproject.build.outputTimestamp=1980-01-01T00:00:02Z";

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    find -name "*.jar"
    asd

    install -Dm644 fop*/target/fop*.jar -t $out/share/fop

    makeWrapper ${jre}/bin/java $out/bin/fop \
        --add-flags "-Dfop.home=$out/share/fop" \
        --add-flags "-jar $out/share/fop/fop-${version}.jar"

    runHook postInstall
  '';

  meta = {
    changelog = "https://xmlgraphics.apache.org/fop/changes.html";
    description = "XML formatter driven by XSL Formatting Objects (XSL-FO)";
    longDescription = ''
      FOP is a Java application that reads a formatting object tree and then
      turns it into a wide variety of output presentations (including AFP, PCL,
      PDF, PNG, PostScript, RTF, TIFF, and plain text), or displays the result
      on-screen.

      The formatting object tree can be in the form of an XML document (output
      by an XSLT engine like xalan) or can be passed in memory as a DOM
      Document or (in the case of xalan) SAX events.

      This package contains the fop command line tool.
    '';
    homepage = "https://xmlgraphics.apache.org/fop/";
    license = lib.licenses.asl20;
    mainProgram = "fop";
    maintainers = with lib.maintainers; [
      bjornfor
      tomasajt
    ];
    platforms = jre.meta.platforms;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # source bundles dependencies as jars
    ];
  };
}
