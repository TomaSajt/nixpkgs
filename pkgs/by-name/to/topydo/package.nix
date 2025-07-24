{
  lib,
  python3,
  fetchFromGitHub,
  fetchpatch,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "topydo";
  version = "0.14";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "topydo";
    repo = "topydo";
    rev = version;
    sha256 = "1lpfdai0pf90ffrzgmmkadbd86rb7250i3mglpkc82aj6prjm6yb";
  };

  patches = [
    # fixes a failing test
    (fetchpatch {
      name = "update-a-test-reference-ics-file.patch";
      url = "https://github.com/topydo/topydo/commit/9373bb4702b512b10f0357df3576c129901e3ac6.patch";
      hash = "sha256-JpyQfryWSoJDdyzbrESWY+RmRbDw1myvTlsFK7+39iw=";
    })
  ];

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    arrow
    icalendar
    prompt-toolkit
    urwid
    watchdog
  ];

  nativeCheckInputs = with python3.pkgs; [
    freezegun
    unittestCheckHook
  ];

  meta = with lib; {
    description = "Cli todo application compatible with the todo.txt format";
    mainProgram = "topydo";
    homepage = "https://github.com/topydo/topydo";
    changelog = "https://github.com/topydo/topydo/blob/${src.rev}/CHANGES.md";
    license = licenses.gpl3Plus;
    maintainers = [ ];
  };
}
