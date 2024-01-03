{ lib
, stdenv
, fetchurl
, ant
, jdk
, makeWrapper
, canonicalize-jars-hook
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fop";
  version = "2.8";

  src = fetchurl {
    url = "mirror://apache/xmlgraphics/fop/fop-${finalAttrs.version}-src.tar.gz";
    hash = "sha256-b7Av17wu6Ar/npKOiwYqzlvBFSIuXTpqTacM1sxtBvc=";
  };

  nativeBuildInputs = [
    ant
    jdk
    makeWrapper
    canonicalize-jars-hook # MESSED UP LINEBREAKS IN MANIFEST
  ];

  buildPhase = ''
    runHook preBuild

    export JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF8"
    # build only the "package" target, which generates the fop command.
    ant -f fop/build.xml package

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib $out/share/doc/fop
    cp fop/build/*.jar fop/lib/*.jar $out/lib/
    cp -r README fop/examples/ $out/share/doc/fop/

    # There is a fop script in the source archive, but it has many impurities.
    # Instead of patching out 90 % of the script, we write our own.
    makeWrapper ${jdk.jre}/bin/java $out/bin/fop \
        --add-flags "-Djava.awt.headless=true" \
        --add-flags "-classpath $out/lib/\*" \
        --add-flags "org.apache.fop.cli.Main"

    runHook postInstall
  '';

  meta = with lib; {
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
    license = licenses.asl20;
    sourceProvenance = with sourceTypes; [
      fromSource
      binaryBytecode # source bundles dependencies as jars
    ];
    mainProgram = "fop";
    maintainers = with maintainers; [ bjornfor tomasajt ];
    platforms = platforms.all;
  };
})
