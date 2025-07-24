{
  lib,
  python3Packages,
  fetchFromGitHub,
  versionCheckHook,
  nixosTests,
  nix-update-script,
  writableTmpDirAsHomeHook,
}:

python3Packages.buildPythonApplication rec {
  pname = "patroni";
  version = "4.0.6";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "zalando";
    repo = "patroni";
    tag = "v${version}";
    sha256 = "sha256-8EodiPVmdDekdsTbv+23ZLHZd8+BQ5v5sQf/SyM1b7Y=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    boto3
    click
    consul
    dnspython
    kazoo
    kubernetes
    prettytable
    psutil
    psycopg2
    pysyncobj
    python-dateutil
    python-etcd
    pyyaml
    tzlocal
    urllib3
    ydiff
  ];

  pythonRemoveDeps = [
    "py-consul" # an optional package that has not been packaged (as of writing this)
  ];

  pythonImportsCheck = [ "patroni" ];

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
    versionCheckHook
    writableTmpDirAsHomeHook
  ];

  versionCheckProgramArg = "--version";

  __darwinAllowLocalNetworking = true;

  passthru = {
    tests.patroni = nixosTests.patroni;

    updateScript = nix-update-script { };
  };

  meta = {
    homepage = "https://patroni.readthedocs.io/en/latest/";
    description = "Template for PostgreSQL HA with ZooKeeper, etcd or Consul";
    changelog = "https://github.com/patroni/patroni/blob/v${version}/docs/releases.rst";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.deshaw ];
  };
}
