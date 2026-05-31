{
  lib,
  makeSetupHook,
  replaceVars,
  makeBinaryWrapper,
  electron,
}:

makeSetupHook
  {
    name = "auto-patchelf-hook";
    propagatedBuildInputs = [
      makeBinaryWrapper
    ];
  }
  (
    replaceVars ./hook.sh {
      electron_exe = lib.getExe electron;
      shim_js = builtins.path { path = ./electron-shim.js; };
    }
  )
