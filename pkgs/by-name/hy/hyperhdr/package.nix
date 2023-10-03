{ lib
, mkDerivation
, fetchFromGitHub
, cmake
, pkg-config
, qtserialport
, alsa-lib
, pipewire
, flatbuffers
, mbedtls
, qmqtt
, xz
}:

let
  mdns-src = fetchFromGitHub {
    owner = "mjansson";
    repo = "mdns";
    rev = "1727be0602941a714cb6048a737f0584b1cebf3c";
    hash = "sha256-2uv+Ibnbl6hsdjFqPhcHXbv+nIEIT4+tgtwGndpZCqo=";
  };
in
mkDerivation {
  pname = "hyperhdr";
  version = "unstable-2023-09-26";

  src = fetchFromGitHub {
    owner = "awawa-dev";
    repo = "HyperHDR";
    rev = "bc366b5444b05d27667502778dd1cd8c7e675586";
    hash = "sha256-A2HkaRxV1zxU87fwiQlWkhvJ0f5CloBS5aAsncWLpbI=";
  };

  postPatch = ''
    rmdir dependencies/external/*
    cp -r --no-preserve=all ${mdns-src} dependencies/external/mdns
  '';

  nativeBuildInputs = [ cmake pkg-config ];

  cmakeFlags = [
    "-DUSE_SYSTEM_FLATBUFFERS_LIBS=ON"
    "-DUSE_SYSTEM_MBEDTLS_LIBS=ON"
    "-DUSE_SYSTEM_MQTT_LIBS=ON"
  ];

  buildInputs = [
    qtserialport
    alsa-lib
    pipewire
    flatbuffers
    mbedtls
    qmqtt
    xz
  ];

  postInstall = ''
    rm -r $out/share/
  '';
}
