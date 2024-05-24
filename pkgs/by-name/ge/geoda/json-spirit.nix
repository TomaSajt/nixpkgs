{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  boost,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "json-spirit";
  version = "4.0.8";

  src = fetchFromGitHub {
    owner = "png85";
    repo = "json_spirit";
    rev = "json_spirit-${finalAttrs.version}";
    hash = "sha256-7O5x4YOPq1hS3Yhjvdtd33s2Lt71fY30oHXZvMZrXzk=";
  };

  strictDeps = true;

  nativeBuildInputs = [ cmake ];

  buildInputs = [ boost ];

  meta = {
    description = "A C++ JSON Parser/Generator Implemented with Boost Spirit";
    homepage = "https://github.com/png85/json_spirit";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomasajt ];
    platforms = lib.platforms.all;
  };
})
