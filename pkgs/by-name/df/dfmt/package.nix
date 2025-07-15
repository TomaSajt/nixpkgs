{
  lib,
  python3Packages,
  fetchPypi,
}:

python3Packages.buildPythonApplication rec {
  pname = "dfmt";
  version = "1.2.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "7af6360ca8d556f1cfe82b97f03b8d1ea5a9d6de1fa3018290c844b6566d9d6e";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'poetry>=' 'poetry-core>=' \
      --replace-fail 'poetry.masonry.api' 'poetry.core.masonry.api'
  '';

  build-system = with python3Packages; [ poetry-core ];

  pythonImportsCheck = [ "dfmt" ];

  meta = with lib; {
    description = "Format paragraphs, comments and doc strings";
    mainProgram = "dfmt";
    homepage = "https://github.com/dmerejkowsky/dfmt";
    license = licenses.bsd3;
    maintainers = with maintainers; [ cole-h ];
  };
}
