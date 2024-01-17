{ lib
, stdenv
, buildDotnetModule
, fetchFromGitHub
, dotnetCorePackages
, wrapGAppsHook
, glfw
, libglvnd
, ffmpeg_5
}:

let
  platform = {
    x86_64-linux = "linux-x86";
    aarch64-linux = "linux-arm64";
    x86_64-darwin = "darwin-x86";
    aarch64-darwin = "darwin-arm64";
  }.${stdenv.system} or (throw "Unsupported platform ${stdenv.system}");
in
buildDotnetModule rec {
  pname = "opentaiko";
  version = "0.6.0-b2";

  src = fetchFromGitHub {
    owner = "0auBSQ";
    repo = "OpenTaiko";
    rev = "Pre-v${version}"; # currently a pre-release
    hash = "sha256-O79uYizx5gNvW2uRwSwt6TLJaxuwMhXB0GF4G/7XUHU=";
  };

  patches = [ ./libs.patch ./egl.patch ];

  dotnet-sdk = dotnetCorePackages.sdk_7_0;
  dotnet-runtime = dotnetCorePackages.runtime_7_0;

  nugetDeps = ./deps.nix;

  buildType = "Debug";

  projectFile = [ "OpenTaiko/OpenTaiko.csproj" ];

  executables = [ "OpenTaiko" ];

  nativeBuildInputs = [ wrapGAppsHook ];

  runtimeDeps = [
    glfw
  ];

  postInstall = ''
    pushd $out/lib/${pname}
    mv Libs/${platform}/* .
    rm -r Libs
    rm -r FFmpeg/*
    ln -s ${lib.getLib ffmpeg_5} FFmpeg
    popd
  '';

  meta = {
    changelog = "https://github.com/0auBSQ/OpenTaiko/releases/tag/${src.rev}";
    description = "A .tja chart player axed on entertainment and creativity. ";
    homepage = "https://github.com/0auBSQ/OpenTaiko";
    license = with lib.licenses; [
      mit
      #unfreeRedistributable # repository contains libbass.so
    ];
    mainProgram = "OpenTaiko";
    maintainers = with lib.maintainers; [ tomasajt ];
  };
}
