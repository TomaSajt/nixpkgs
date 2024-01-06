{ lib
, stdenv
, gradle
, jdk11
}:

let

  version = "5.3.0";

  jdk = jdk11;
  gradleWithJdk = gradle.override { java = jdk; };

  # fake build to pre-download deps into fixed-output derivation
  deps = stdenv.mkDerivation {
    name = "${pname}-${version}-deps";
    inherit src;

    nativeBuildInputs = [ gradleWithJdk perl ];

    buildPhase = ''
      export GRADLE_USER_HOME=$(mktemp -d)
      gradle --no-daemon resolveDependencies
    '';
    # perl code mavenizes pathes (com.squareup.okio/okio/1.13.0/a9283170b7305c8d92d25aff02a6ab7e45d06cbe/okio-1.13.0.jar -> com/squareup/okio/okio/1.13.0/okio-1.13.0.jar)
    installPhase = ''
      find $GRADLE_USER_HOME/caches/modules-2 -type f -regex '.*\.\(jar\|pom\)' \
        | perl -pe 's#(.*/([^/]+)/([^/]+)/([^/]+)/[0-9a-f]{30,40}/([^/\s]+))$# ($x = $2) =~ tr|\.|/|; "install -Dm444 $1 \$out/$x/$3/$4/$5" #e' \
        | sh
    '';
    outputHashMode = "recursive";
    outputHash = "sha256-hbWLsWorEo+1BBURvrFMXpxvZjJBZ1p7HVlJN5e5JZc=";
  };
in
stdenv.mkDerivation { }
