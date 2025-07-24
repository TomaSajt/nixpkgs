{
  python3Packages,
  fetchFromGitHub,
  gcc,
  lib,
}:

python3Packages.buildPythonApplication rec {
  pname = "resolve-march-native";
  version = "6.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "hartwork";
    repo = "resolve-march-native";
    tag = version;
    hash = "sha256-YJvKLHxn80RRVEOGeg9BwxhDZ8Hhg5Qa6ryLOXumY5w=";
  };

  build-system = with python3Packages; [ setuptools ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  makeWrapperArgs = [
    # NB: The tool uses gcc at runtime to resolve the -march=native flags
    "--prefix PATH : ${lib.makeBinPath [ gcc ]}"
  ];

  meta = with lib; {
    description = "Tool to determine what GCC flags -march=native would resolve into";
    mainProgram = "resolve-march-native";
    homepage = "https://github.com/hartwork/resolve-march-native";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ lovesegfault ];
    platforms = platforms.unix;
  };
}
