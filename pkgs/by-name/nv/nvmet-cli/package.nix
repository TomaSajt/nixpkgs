{
  lib,
  python3Packages,
  fetchurl,
}:

python3Packages.buildPythonApplication rec {
  pname = "nvmet-cli";
  version = "0.7";
  pyproject = true;

  src = fetchurl {
    url = "ftp://ftp.infradead.org/pub/nvmetcli/nvmetcli-${version}.tar.gz";
    sha256 = "051y1b9w46azy35118154c353v3mhjkdzh6h59brdgn5054hayj2";
  };

  build-system = with python3Packages; [ setuptools ];

  buildInputs = with python3Packages; [ nose2 ];

  dependencies = with python3Packages; [
    configshell-fb
    six
  ];

  # This package requires the `nvmet` kernel module to be loaded for tests.
  doCheck = false;

  pythonImportsCheck = [ "nvmet" ];

  meta = with lib; {
    description = "NVMe target CLI";
    mainProgram = "nvmetcli";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ hoverbear ];
  };
}
