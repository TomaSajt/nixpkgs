{
  lib,
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
  cacert,
  unzip,
  pkg-config,
  libGL,
  libX11,
  libXcursor,
  libXrandr,
  libXinerama,
  libXi,
  libXxf86vm,
  mupdf,
  fontconfig,
  freetype,
  stdenv,
  darwin,
}:

buildGoModule rec {
  pname = "gcs";
  version = "5.22.0";

  src = fetchFromGitHub {
    owner = "richardwilkes";
    repo = "gcs";
    rev = "v${version}";
    hash = "sha256-OF4Sjx15gxqDNdJiZ8cNItX0+xZqThf+2rSvfp5s+Mg=";

    nativeBuildInputs = [
      cacert
      unzip
    ];

    # also fetch pdf.js, which is no longer vendored in-tree
    postFetch = ''
      cd $out/server/pdf
      substituteInPlace refresh-pdf.js.sh \
          --replace-fail '/bin/rm' 'rm'
      . refresh-pdf.js.sh
    '';
  };

  modPostBuild = ''
    chmod +w vendor/github.com/richardwilkes/pdf
    sed -i 's|-lmupdf[^ ]* |-lmupdf |g' vendor/github.com/richardwilkes/pdf/pdf.go
  '';

  vendorHash = "sha256-pPAWYFhWE1WX70WfzElJNuHRVbUIRjcpZB7AwFmDi8g=";

  frontend = buildNpmPackage {
    name = "${pname}-${version}-frontend";

    inherit src;
    sourceRoot = "${src.name}/server/frontend";

    npmDepsHash = "sha256-6hKrp6hbDqPpKXlzS7nvosDBiadPWKl6WSQ2J8+8WPY=";

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r dist $out/dist
      runHook postInstall
    '';
  };

  postPatch = ''
    cp -r ${frontend}/dist server/frontend/dist
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs =
    [
      libGL
      libX11
      libXcursor
      libXrandr
      libXinerama
      libXi
      libXxf86vm
      mupdf
      fontconfig
      freetype
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk_11_0.frameworks.Carbon
      darwin.apple_sdk_11_0.frameworks.Cocoa
      darwin.apple_sdk_11_0.frameworks.Kernel
    ];

  # flags are based on https://github.com/richardwilkes/gcs/blob/master/build.sh
  flags = [ "-a" ];
  ldflags = [
    "-s"
    "-w"
    "-X github.com/richardwilkes/toolbox/cmdline.AppVersion=${version}"
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $GOPATH/bin/gcs -t $out/bin
    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/richardwilkes/gcs/releases/tag/${src.rev}";
    description = "A stand-alone, interactive, character sheet editor for the GURPS 4th Edition roleplaying game system";
    homepage = "https://gurpscharactersheet.com/";
    license = lib.licenses.mpl20;
    mainProgram = "gcs";
    maintainers = with lib.maintainers; [ tomasajt ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    # incompatible vendor/github.com/richardwilkes/unison/internal/skia/libskia_linux.a
    broken = stdenv.isLinux && stdenv.isAarch64;
  };
}
