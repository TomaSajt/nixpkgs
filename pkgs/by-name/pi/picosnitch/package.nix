{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "picosnitch";
  version = "1.0.3";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "78285e91b5c4d8e07529a34a7c3fe606acb6f950ee3cc78bb6c346bc2195b68a";
  };

  prePatch = ''
    substituteInPlace picosnitch.py \
      --replace-fail '/run/picosnitch.pid' '/run/picosnitch/picosnitch.pid'
  '';

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    setuptools
    bcc
    psutil
    dbus-python
    requests
    pandas
    plotly
    dash
    geoip2
  ];

  pythonImportsCheck = [ "picosnitch" ];

  meta = with lib; {
    description = "Monitor network traffic per executable with hashing";
    mainProgram = "picosnitch";
    homepage = "https://github.com/elesiuta/picosnitch";
    changelog = "https://github.com/elesiuta/picosnitch/releases";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.elesiuta ];
    platforms = platforms.linux;
    knownVulnerabilities = [
      "Allows an unprivileged user to write to arbitrary files as root; see https://github.com/elesiuta/picosnitch/issues/40"
    ];
  };
}
