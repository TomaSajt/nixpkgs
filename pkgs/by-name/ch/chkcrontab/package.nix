{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "chkcrontab";
  version = "1.7";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "0gmxavjkjkvjysgf9cf5fcpk589gb75n1mn20iki82wifi1pk1jn";
  };

  postPatch = ''
    # the doc directory is missing from the PyPI sources
    substituteInPlace setup.py \
      --replace-fail "['doc/chkcrontab.1']" "[]"
  '';

  build-system = with python3.pkgs; [ setuptools ];

  nativeCheckInputs = with python3.pkgs; [ pytestCheckHook ];

  preCheck = ''
    substituteInPlace tests/test_check.py \
      --replace-fail "assertEquals" "assertEqual"
  '';

  pythonImportsCheck = [ "chkcrontab_lib" ];

  meta = with lib; {
    description = "Tool to detect crontab errors";
    mainProgram = "chkcrontab";
    license = licenses.asl20;
    maintainers = [ ];
    homepage = "https://github.com/lyda/chkcrontab";
  };
}
