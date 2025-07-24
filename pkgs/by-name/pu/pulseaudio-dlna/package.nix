{
  fetchFromGitHub,
  lib,
  python3Packages,

  wrapGAppsHook3,
  gobject-introspection,
  mp3Support ? true,
  lame,
  opusSupport ? true,
  opusTools,
  faacSupport ? false,
  faac,
  flacSupport ? true,
  flac,
  soxSupport ? true,
  sox,
  vorbisSupport ? true,
  vorbis-tools,
  pulseaudio,
}:

python3Packages.buildPythonApplication {
  pname = "pulseaudio-dlna";
  version = "unstable-2021-11-09";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Cygn";
    repo = "pulseaudio-dlna";
    rev = "637a2e7bba2277137c5f12fb58e63100dab7cbe6";
    sha256 = "sha256-Oda+zQQJE2D3fiNWTzxYvI8cZVHG5JAoV2Wf5Z6IU3M=";
  };

  build-system = with python3Packages; [
    setuptools
    wrapGAppsHook3 # NOTE: DON'T MERGE, REQUIRES TESTING
    gobject-introspection
  ];

  dependencies = with python3Packages; [
    docopt
    chardet
    dbus-python
    docopt
    requests
    setproctitle
    protobuf
    lxml
    netifaces
    zeroconf
    urllib3
    psutil
    pyroute2
    notify2
    pychromecast

    setuptools # pkg_resources is imported during runtime
  ];

  makeWrapperArgs =
    let
      # pulseaudio-dlna shells out to pactl to configure sinks and sources.
      # As pactl might not be in $PATH, add --suffix it (so pactl configured by the
      # user get priority)
      runtimeDeps =
        [ pulseaudio ]
        ++ lib.optional mp3Support lame
        ++ lib.optional opusSupport opusTools
        ++ lib.optional faacSupport faac
        ++ lib.optional flacSupport flac
        ++ lib.optional soxSupport sox
        ++ lib.optional vorbisSupport vorbis-tools;
    in
    [ "--suffix PATH : ${lib.makeBinPath runtimeDeps}" ];

  # upstream has no tests
  checkPhase = ''
    $out/bin/pulseaudio-dlna --help > /dev/null
  '';

  meta = with lib; {
    description = "Lightweight streaming server which brings DLNA / UPNP and Chromecast support to PulseAudio and Linux";
    mainProgram = "pulseaudio-dlna";
    homepage = "https://github.com/Cygn/pulseaudio-dlna";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ mog ];
    platforms = platforms.linux;
  };
}
