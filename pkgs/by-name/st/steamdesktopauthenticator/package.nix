{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
}:


buildDotnetModule rec {
  pname = "dotnet-space-test";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "TomaSajt";
    repo = "dotnet-space-test";
    rev = "c25982c7343a7b6c05e8275c90d7f2884730acdb";
    hash = "sha256-Io5eYnmPxSOePytOfWyVIw1CwU/M5iTKHQz9oH2zozo=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  nugetDeps = ./deps.nix;

  projectFile = [
    "Dotnet Space Test/Dotnet Space Test.csproj"
  ];

  testProjectFile = [
  ];



  meta = {
    changelog = "https://github.com/Jessecar96/SteamDesktopAuthenticator/releases/tag/${src.rev}";
    description = "Desktop implementation of Steam's mobile authenticator app";
    homepage = "https://github.com/Jessecar96/SteamDesktopAuthenticator";
    license = lib.licenses.mit;
    mainProgram = "SteamDesktopAuthenticator";
    maintainers = with lib.maintainers; [ tomasajt ];
  };
}
