{
  lib,
  buildDubPackage,
  fetchFromGitHub,
}:

buildDubPackage {
  pname = "provision-anisette-server";
  version = "2.2.0-unstable-2024-12-22";

  src = fetchFromGitHub {
    owner = "Dadoum";
    repo = "Provision";
    rev = "645d56d8e8c86c057893321843db00b21f1aaeb2";
    hash = "sha256-YTuyM5PEB9YnT24e9moM0YlTmO0WW0cDBbjAAqtB+Dk=";
  };

  patches = [
    ./fix-deps.patch
  ];

  dubLock = ./dub-lock.json;
  dubFlags = [ ":anisette-server" ];

  installPhase = ''
    install -Dm755 bin/provision_anisette-server $out/bin/anisette-server
  '';

  meta = {
    description = "Set of tools interacting with Apple servers.";
    homepage = "https://github.com/Dadoum/Provision";
    license = [
      lib.licenses.lgpl2Only
      lib.licenses.gpl2Only
    ];
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
}
