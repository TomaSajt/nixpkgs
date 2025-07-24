{
  lib,
  fetchurl,
  python3Packages,
  autoPatchelfHook,
}:

python3Packages.buildPythonApplication rec {
  pname = "quast";
  version = "5.3.0";
  pyproject = true; # TODO: DON'T MERGE BEFORE TESTING!

  src = fetchurl {
    url = "https://github.com/ablab/quast/releases/download/quast_${version}/quast-${version}.tar.gz";
    hash = "sha256-rJ26A++dClHXqeLFaCYQTnjzQPYmOjrTk2SEQt68dOw=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    distutils
    simplejson
    joblib
  ];

  postPatch = ''
    #substituteInPlace quast_libs/bedtools/Makefile \
    #  --replace-fail "/bin/bash" "bash"
  '';

  postFixup = ''
    # Link to the master program
    ln -s $out/bin/quast.py $out/bin/quast
  '';

  dontPatchELF = true;

  # Tests need to download data files, so manual run after packaging is needed
  doCheck = false;

  meta = {
    description = "Evaluates genome assemblies by computing various metrics";
    homepage = "https://github.com/ablab/quast";
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode # source bundles binary dependencies
    ];
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.bzizou ];
    platforms = lib.platforms.all;
  };
}
