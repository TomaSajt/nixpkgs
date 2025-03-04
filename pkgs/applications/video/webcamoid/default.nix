{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  libxcb,
  cmake,
  qt6Packages,
  ffmpeg,
  gst_all_1,
  libpulseaudio,
  alsa-lib,
  jack2,
  v4l-utils,
}:

stdenv.mkDerivation rec {
  pname = "webcamoid";
  version = "9.2.3";

  src = fetchFromGitHub {
    owner = "webcamoid";
    repo = "webcamoid";
    tag = version;
    hash = "sha256-j4FiRQeFsrZD48P1CUESFytz9l/64Lz1EuOZp0ZSEmI=";
  };

  buildInputs = [
    libxcb
    qt6Packages.qtbase
    qt6Packages.qtdeclarative
    qt6Packages.qtsvg
    ffmpeg
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    alsa-lib
    libpulseaudio
    jack2
    v4l-utils
  ];

  nativeBuildInputs = [
    pkg-config
    cmake
    qt6Packages.wrapQtAppsHook
  ];

  meta = {
    description = "Webcam Capture Software";
    longDescription = "Webcamoid is a full featured and multiplatform webcam suite.";
    homepage = "https://github.com/webcamoid/webcamoid/";
    license = with lib.licenses; [ gpl3Plus ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ robaca ];
    mainProgram = "webcamoid";
  };
}
