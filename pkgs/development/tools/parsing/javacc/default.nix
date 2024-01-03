{ lib
, stdenv
, fetchFromGitHub
, ant
, jdk
, jre
, makeWrapper
, canonicalize-jars-hook
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "javacc";
  version = "7.0.13";

  src = fetchFromGitHub {
    owner = "javacc";
    repo = "javacc";
    rev = "javacc-${finalAttrs.version}";
    hash = "sha256-nDJvKIbJc23Tvfn7Zqvt5tDDffNf4KQ0juGQQCZ+i1c=";
  };

  nativeBuildInputs = [
    ant
    jdk
    makeWrapper
    canonicalize-jars-hook
  ];

  buildPhase = ''
    ant jar
  '';

  installPhase = ''
    mkdir -p $out/target
    mv target/javacc.jar $out/target
    chmod +x scripts/jjrun
    mv scripts $out/bin
    find -L "$out/bin" -type f -executable -print0 \
      | while IFS= read -r -d ''' file; do
      wrapProgram "$file" --suffix PATH : ${jre}/bin
    done
  '';

  doCheck = true;

  checkPhase = ''
    ant test
  '';

  meta = with lib; {
    changelog = "https://github.com/javacc/javacc/blob/${finalAttrs.src.rev}/docs/release-notes.md";
    description = "A parser generator for building parsers from grammars";
    homepage = "https://javacc.github.io/javacc";
    license = licenses.bsd2;
    mainProgram = "javacc";
    maintainers = teams.deshaw.members;
  };
})
