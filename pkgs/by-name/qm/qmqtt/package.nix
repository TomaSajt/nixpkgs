{ lib
, mkDerivation
, fetchFromGitHub
, cmake
, qtbase
}:

mkDerivation rec {
  pname = "qmqtt";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "emqx";
    repo = "qmqtt";
    rev = "refs/tags/v${version}";
    hash = "sha256-JLGwEF5e/IKzPzCQBzB710REGWbc/MW+r5AHmyYUkUI=";
  };

  nativeBuildInputs = [ cmake ];
}
