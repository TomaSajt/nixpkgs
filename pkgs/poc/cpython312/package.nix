{ mkPackage }:

mkPackage (finalAttrs: {
  pname = "cpython";
  version = "3.12.0";

  pythonPackages = import ./mk-python-package-set.nix finalAttrs.finalPackage;

})
