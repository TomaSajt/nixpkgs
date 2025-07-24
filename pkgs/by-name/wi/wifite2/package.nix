{
  lib,
  fetchFromGitHub,
  fetchpatch,
  python3Packages,
  wirelesstools,
  aircrack-ng,
  wireshark-cli,
  reaverwps-t6x,
  cowpatty,
  hashcat,
  hcxtools,
  hcxdumptool,
  which,
  bully,
  pixiewps,
  john,
  iw,
  macchanger,
}:

let
  runtimeDeps = [
    aircrack-ng
    wireshark-cli
    reaverwps-t6x
    cowpatty
    hashcat
    hcxtools
    hcxdumptool
    wirelesstools
    which
    bully
    pixiewps
    john
    iw
    macchanger
  ];
in
python3Packages.buildPythonApplication rec {
  pname = "wifite2";
  version = "2.7.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kimocoder";
    repo = "wifite2";
    rev = version;
    hash = "sha256-G2AKKZUDS2UQm95TEhGJIucyMRcm7oL0d3J8uduEQhw=";
  };

  patches = [
    (fetchpatch {
      url = "https://salsa.debian.org/pkg-security-team/wifite/raw/debian/2.7.0-1/debian/patches/Disable-aircrack-failing-test.patch";
      hash = "sha256-BUAowBajfnZ1x6Z3Ce3L0rAERv7v/KrdHcdvKxTxSrM=";
    })
    (fetchpatch {
      url = "https://salsa.debian.org/pkg-security-team/wifite/raw/debian/2.7.0-1/debian/patches/Disable-two-failing-tests.patch";
      hash = "sha256-wCwfNkF/GvOU5FWPmQ3dJ4Txthz9T9TO2xhSL5vllQc=";
    })
    (fetchpatch {
      url = "https://salsa.debian.org/pkg-security-team/wifite/raw/debian/2.7.0-1/debian/patches/fix-for-new-which.patch";
      hash = "sha256-8xs+O2ILSRcvsw2pyx2gEBFHdduoI+xmUvDBchKz2Qs=";
    })
  ];

  build-system = with python3Packages; [ setuptools ];

  pythonRemoveDeps = [
    "argparse" # argparse is part of python3
  ];

  dependencies = with python3Packages; [
    chardet
    scapy
  ];

  nativeCheckInputs = [ python3Packages.unittestCheckHook ] ++ runtimeDeps;

  makeWrapperArgs = [ "--prefix PATH : ${lib.makeBinPath runtimeDeps}" ];

  meta = with lib; {
    homepage = "https://github.com/kimocoder/wifite2";
    description = "Rewrite of the popular wireless network auditor, wifite";
    mainProgram = "wifite";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [
      lassulus
      danielfullmer
      d3vil0p3r
    ];
  };
}
