{
  buildDubPackage,
  fetchFromGitHub,
  autoPatchelfHook,
}:

buildDubPackage {
  pname = "electonvolt";
  version = "dev";

  src = fetchFromGitHub {
    owner = "gecko0307";
    repo = "electronvolt";
    rev = "1750d588d37073b8538eacb2f35258a4bf819881";
    hash = "sha256-XJzlDU/wY/zfe3Hv3LxeDZ+0JaDQlCL1i3E01T/wDYQ=";
  };

  postPatch = ''
    substituteInPlace dub.json \
        --replace-fail "~master" "0.16.0"
  '';

  nativeBuildInputs = [ autoPatchelfHook ];

  dubDeps = ./deps.nix;

  dubFlags = "--build=release-nobounds";

  installPhase = ''
    install -Dm755 electronvolt -t $out/bin
    #install -Dm755 *so -t $out/lib
    mkdir -p $out/share/electronvolt
    cp -r data gamecontrollerdb.txt *so $out/share/electronvolt
  '';
}
