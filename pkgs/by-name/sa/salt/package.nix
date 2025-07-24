{
  lib,
  stdenv,
  python3,
  fetchpatch,
  fetchPypi,
  replaceVars,
  openssl,
  # Many Salt modules require various Python modules to be installed,
  # passing them in this array enables Salt to find them.
  extraInputs ? [ ],
}:

python3.pkgs.buildPythonApplication rec {
  pname = "salt";
  version = "3007.6";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-F2qLl8Q8UO2H3xInmz3SSLu2q0jNMrLekPRSNMfE0JQ=";
  };

  patches = [
    (replaceVars ./fix-libcrypto-loading.patch {
      libcrypto = "${lib.getLib openssl}/lib/libcrypto${stdenv.hostPlatform.extensions.sharedLibrary}";
    })
    (fetchpatch {
      name = "urllib.patch";
      url = "https://src.fedoraproject.org/rpms/salt/raw/1c6e7b7a88fb81902f5fcee32e04fa80713b81f8/f/urllib.patch";
      hash = "sha256-yldIurafduOAYpf2X0PcTQyyNjz5KKl/N7J2OTEF/c0=";
    })
  ];

  postPatch = ''
    substituteInPlace requirements/base.txt \
      --replace-fail contextvars ""

    # Don't require optional dependencies on Darwin, let's use
    # `extraInputs` like on any other platform
    echo -n > "requirements/darwin.txt"
  '';

  build-system = with python3.pkgs; [ setuptools ];

  dependencies =
    with python3.pkgs;
    [
      distro
      jinja2
      jmespath
      looseversion
      markupsafe
      msgpack
      packaging
      psutil
      pycryptodomex
      pyyaml
      pyzmq
      requests
      tornado
    ]
    ++ extraInputs;

  # Don't use fixed dependencies on Darwin
  env.USE_STATIC_REQUIREMENTS = "0";

  # The tests fail due to socket path length limits at the very least;
  # possibly there are more issues but I didn't leave the test suite running
  # as is it rather long.
  doCheck = false;

  meta = {
    homepage = "https://saltproject.io/";
    changelog = "https://docs.saltproject.io/en/latest/topics/releases/${version}.html";
    description = "Portable, distributed, remote execution and configuration management system";
    maintainers = with lib.maintainers; [ Flakebi ];
    license = lib.licenses.asl20;
  };
}
