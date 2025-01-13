python:

let
  inherit (python.__pkgs) mkPackage lib;
in

let
  extendAttrs = finalAttrs: prevAttrs: {
    __python = python;
  };
in

let
  mkPythonPackage =
    rattrs:
    let
      # don't make overridable
      rattrs' = lib.extends extendAttrs rattrs;
    in
    mkPackage rattrs';
in

mkPythonPackage
