{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  voicevox-core,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "voicevox-engine";
  version = "0.20.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "VOICEVOX";
    repo = "voicevox_engine";
    rev = "refs/tags/${finalAttrs.version}";
    hash = "sha256-Gib5R7oleg+XXyu2V65EqrflQ1oiAR7a09a0MFhSITc=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  # populate speaker_info directory with the actual model metadata
  configurePhase = ''
    runHook preConfigure

    rm -r resources/character_info
    cp -r --no-preserve=all ${finalAttrs.passthru.resources}/character_info resources/character_info

    pushd resources/character_info
    for dir in *; do
        rm $dir/*/*.png_large
        mv $dir ''${dir#*"_"}
    done
    popd

    runHook postConfigure
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/voicevox-engine
    cp -r voicevox_engine resources run.py engine_manifest.json presets.yaml $out/share/voicevox-engine

    makeWrapper ${finalAttrs.passthru.python.interpreter} $out/bin/voicevox-engine \
        --add-flags "$out/share/voicevox-engine/run.py" \
        --add-flags "--voicelib_dir=${voicevox-core}/lib"

    runHook postInstall
  '';

  passthru = {
    resources = fetchFromGitHub {
      owner = "VOICEVOX";
      repo = "voicevox_resource";
      rev = "refs/tags/${finalAttrs.version}";
      hash = "sha256-m888DF9qgGbK30RSwNnAoT9D0tRJk6cD5QY72FRkatM=";
    };

    pyopenjtalk = python3.pkgs.callPackage ./pyopenjtalk.nix { };

    python = python3.withPackages (
      ps: with ps; [
        setuptools
        python
        numpy
        # override can be removed after https://github.com/NixOS/nixpkgs/issues/335841 is resolved
        (fastapi.overrideAttrs {
          postInstall = ''
            rm -r $out/bin
          '';
        })
        python-multipart
        uvicorn
        soundfile
        pyyaml
        pyworld
        jinja2
        finalAttrs.passthru.pyopenjtalk
        semver
        platformdirs
        soxr
        pydantic
        starlette
      ]
    );
  };

  meta = {
    changelog = "https://github.com/VOICEVOX/voicevox_engine/releases/tag/${finalAttrs.version}";
    description = "Engine for the VOICEVOX speech synthesis software";
    homepage = "https://github.com/VOICEVOX/voicevox_engine";
    license = lib.licenses.lgpl3Only;
    mainProgram = "voicevox-engine";
    maintainers = with lib.maintainers; [ tomasajt ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
