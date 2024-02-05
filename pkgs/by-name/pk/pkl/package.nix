{ lib
, stdenv
, fetchFromGitHub
, gradle_7
, perl
, makeWrapper
, jre
, graalvm-ce
}:

let
  gradle = gradle_7;

  pname = "pkl";
  version = "0.25.1";

  src = fetchFromGitHub {
    owner = "apple";
    repo = "pkl";
    rev = version;
    hash = "sha256-/I1dxGXYVUClEQXXtSqEyopClNTqseeWpAiyeaPrIGo=";
  };

  patches = [
    ./fix-commit-id.patch
    ./graalvm.patch
  ];

  # fake build to pre-download deps into fixed-output derivation
  deps = stdenv.mkDerivation {
    name = "${pname}-${version}-deps";
    inherit src patches;

    nativeBuildInputs = [ gradle graalvm-ce perl ];

    buildPhase = ''
      export GRADLE_USER_HOME=$(mktemp -d)
      gradle --no-daemon --console=plain --stacktrace -DreleaseBuild=true -PbuildInfo.commitId=nixpkgs pkl-cli:buildNative
    '';

    # perl code mavenizes pathes (com.squareup.okio/okio/1.13.0/a9283170b7305c8d92d25aff02a6ab7e45d06cbe/okio-1.13.0.jar -> com/squareup/okio/okio/1.13.0/okio-1.13.0.jar)
    installPhase = ''
      find $GRADLE_USER_HOME/caches/modules-2 -type f -regex '.*\.\(jar\|pom\)' \
        | perl -pe 's#(.*/([^/]+)/([^/]+)/([^/]+)/[0-9a-f]{30,40}/([^/\s]+))$# ($x = $2) =~ tr|\.|/|; "install -Dm444 $1 \$out/$x/$3/$4/$5" #e' \
        | sh
    '';

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-qfLtqs4odmCi6AI+3eEYp9K0ybqylgjZl5pNhLzYcNA=";
  };
in
stdenv.mkDerivation {
  inherit pname version src patches deps;

  nativeBuildInputs = [ gradle graalvm-ce ];

  postPatch = ''
    sed -i 's#mavenCentral()#maven { url = uri("${deps}") }#g' settings.gradle.kts buildSrc/settings.gradle.kts
  '';

  buildPhase = ''
    runHook preBuild

    export GRADLE_USER_HOME=$(mktemp -d)
    gradle --offline --no-daemon --console=plain -DreleaseBuild=true -PbuildInfo.commitId=nixpkgs pkl-cli:buildNative

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    dir -R
    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/apple/pkl/releases/tag/${src.rev}";
    description = "A configuration as code language with rich validation and tooling";
    homepage = "https://github.com/apple/pkl";
    license = lib.licenses.gpl3Only;
    mainProgram = "pkl";
    maintainers = with lib.maintainers; [ tomasajt ];
    platforms = jre.meta.platforms;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # deps
    ];
  };
}
