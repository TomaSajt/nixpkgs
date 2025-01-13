finalAttrs: {
  pname = "some-python-package";
  version = "1.0";

  build-system = with finalAttrs.__pythonBuildHost.pythonPackages; [ ];

  #dependencies = with finalAttrs.__python.pythonPackages; [ another-python-package ];
}
