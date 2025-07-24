{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "kerbrute";
  version = "0.0.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ok/yttRSkCaEdV4aM2670qERjgDBll6Oi3L5TV5YEEA=";
  };

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    impacket
  ];

  # This package does not have any tests
  doCheck = false;

  installChechPhase = ''
    $out/bin/kerbrute --version
  '';

  pythonImportsCheck = [ "kerbrute" ];

  meta = {
    homepage = "https://github.com/TarlogicSecurity/kerbrute";
    description = "Kerberos bruteforce utility";
    mainProgram = "kerbrute";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ applePrincess ];
  };
}
