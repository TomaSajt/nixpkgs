{
  lib,
  fetchFromGitHub,
  python3,
  bash,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "htgettoken";
  version = "2.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "fermitools";
    repo = "htgettoken";
    tag = "v${version}";
    hash = "sha256-3xBACXxH5G1MO2dNFFSL1Rssc8RdauvLZ4Tx2djOgyw=";
  };

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    gssapi
    paramiko
    urllib3
  ];

  buildInputs = [
    bash # for the shell scripts in $out/bin
  ];

  meta = with lib; {
    description = "Gets OIDC authentication tokens for High Throughput Computing via a Hashicorp vault server ";
    license = licenses.bsd3;
    homepage = "https://github.com/fermitools/htgettoken";
    maintainers = with maintainers; [ veprbl ];
  };
}
