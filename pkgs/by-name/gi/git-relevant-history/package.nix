{
  lib,
  fetchFromGitHub,
  python3,
  git,
  git-filter-repo,
}:

python3.pkgs.buildPythonApplication {
  pname = "git-relevant-history";
  version = "2022-09-15";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "rainlabs-eu";
    repo = "git-relevant-history";
    rev = "84552324d7cb4790db86282fc61bf98a05b7a4fd";
    hash = "sha256-46a6TR1Hi3Lg2DTmOp1aV5Uhd4IukTojZkA3TVbTnRY=";
  };

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [ docopt ];

  makeWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        git
        git-filter-repo
      ]
    }"
  ];

  pythonImportsCheck = [ "gitrelevanthistory.main" ];

  meta = with lib; {
    description = "Extract only relevant history from git repo";
    homepage = "https://github.com/rainlabs-eu/git-relevant-history";
    license = licenses.asl20;
    platforms = platforms.all;
    maintainers = [ maintainers.bendlas ];
    mainProgram = "git-relevant-history";
  };
}
