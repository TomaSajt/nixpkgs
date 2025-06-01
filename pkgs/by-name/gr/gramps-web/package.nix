{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "gramps-web";
  version = "25.5.2";

  src = fetchFromGitHub {
    owner = "gramps-project";
    repo = "gramps-web";
    rev = "v${version}";
    hash = "sha256-Ed+IIhteYk37YnWF+m3s+lHx3KnQ1fTkiGhFBhgD5XQ=";
  };

  npmDepsHash = "sha256-mmhRchUbfDh8jyPRBJlxtUpdsQq0KhcCW9NcCC8Qq+s=";

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r dist $out/dist

    runHook postInstall
  '';

  meta = {
    description = "Open Source Online Genealogy System";
    homepage = "https://github.com/gramps-project/gramps-web";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "gramps-web";
    platforms = lib.platforms.all;
  };
}
