{
  lib,
  python3Packages,
  fetchFromGitHub,
  gitMinimal,
}:

python3Packages.buildPythonApplication rec {
  pname = "git-aggregator";
  version = "4.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "acsone";
    repo = "git-aggregator";
    tag = version;
    hash = "sha256-sZYh3CN15WTCQ59W24ERJdP48EJt571cbkswLQ3JL2g=";
  };

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    argcomplete
    colorama
    kaptan
    requests
  ];

  makeWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ gitMinimal ]}"
  ];

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
    gitMinimal
  ];

  preCheck = ''
    export HOME="$(mktemp -d)"
    git config --global user.name John
    git config --global user.email john@localhost
    git config --global init.defaultBranch master
    git config --global pull.rebase false
  '';

  meta = with lib; {
    description = "Manage the aggregation of git branches from different remotes to build a consolidated one";
    homepage = "https://github.com/acsone/git-aggregator";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ bbjubjub ];
    mainProgram = "gitaggregate";
  };
}
