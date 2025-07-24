{
  lib,
  fetchFromGitHub,
  fetchpatch,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "pylint-exit";
  version = "1.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jongracecox";
    repo = "pylint-exit";
    rev = "v${version}";
    sha256 = "0hwfny48g394visa3xd15425fsw596r3lhkfhswpjrdk2mnk3cny";
  };

  patches = [
    # https://github.com/jongracecox/pylint-exit/pull/7
    (fetchpatch {
      name = "remove-m2r.patch";
      url = "https://github.com/jongracecox/pylint-exit/commit/c7635fe8a482804490e06c206d21e7e453b04fd4.patch";
      hash = "sha256-MTArQeGFZKnJLcxVrUMmXWCQBBLoTzZhz+HSh9lR5C4=";
    })
  ];

  # Converting the shebang manually as it is not picked up by patchShebangs
  postPatch = ''
    substituteInPlace pylint_exit.py \
      --replace-fail "#!/usr/local/bin/python" "#!${python3Packages.python.interpreter}"
  '';

  build-system = with python3Packages; [ setuptools ];

  # setup.py reads its version from the TRAVIS_TAG environment variable
  env.TRAVIS_TAG = version;

  checkPhase = ''
    ${python3Packages.python.interpreter} -m doctest pylint_exit.py
  '';

  pythonImportsCheck = [ "pylint_exit" ];

  meta = with lib; {
    description = "Utility to handle pylint exit codes in an OS-friendly way";
    license = licenses.mit;
    homepage = "https://github.com/jongracecox/pylint-exit";
    maintainers = [ maintainers.fabiangd ];
  };
}
