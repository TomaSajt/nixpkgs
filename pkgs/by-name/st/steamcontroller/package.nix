{
  lib,
  fetchFromGitHub,
  python3Packages,
  libusb1,
  linuxHeaders,
}:

python3Packages.buildPythonApplication {
  pname = "steamcontroller";
  version = "2017-08-11";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ynsta";
    repo = "steamcontroller";
    rev = "80928ce237925e0d0d7a65a45b481435ba6b931e";
    sha256 = "0lv9j2zv8fmkmc0x9r7fa8zac2xrwfczms35qz1nfa1hr84wniid";
  };

  postPatch = ''
    substituteInPlace src/uinput.py --replace-fail \
      "/usr/include" "${linuxHeaders}/include"
  '';

  buildInputs = [ libusb1 ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = [
    python3Packages.psutil
    python3Packages.libusb1
  ];

  doCheck = false;
  pythonImportsCheck = [ "steamcontroller" ];

  meta = with lib; {
    description = "Standalone Steam controller driver";
    homepage = "https://github.com/ynsta/steamcontroller";
    license = licenses.mit;
    maintainers = with maintainers; [ rnhmjoj ];
    platforms = platforms.linux;
  };
}
