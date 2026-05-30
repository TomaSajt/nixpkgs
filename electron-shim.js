const { app } = require("electron");

const getEnvOrExit = (v) => {
  const res = process.env[v];
  if (!res) {
    console.error(`${v} is not set, exiting...`);
    app.exit();
  }
  return res;
};

const appPath = getEnvOrExit("ELECTRON_SHIM_APP_PATH");
const exePath = getEnvOrExit("ELECTRON_SHIM_EXE_PATH");
const assetsPath = getEnvOrExit("ELECTRON_SHIM_ASSETS_PATH");

console.log(process.argv);

process.argv[0] = exePath;
console.log(process.argv);

const shimArgvInd = process.argv.findIndex((arg) => {
  console.log(arg);
  return arg.endsWith("electron-shim.js");
});
if (shimArgvInd === -1) {
  console.error("electron-shim.js was not found in argv, exiting...");
}
process.argv.splice(shimArgvInd, 1);

console.log(process.argv);

app.setPath("exe", exePath); // This also makes app.isPackaged give true as a result

app.setPath("assets", assetsPath);

console.log('app.getPath("exe") == ', app.getPath("exe"));
console.log('app.getPath("assets") == ', app.getPath("assets"));
console.log("app.isPackaged == ", app.isPackaged);

// The value of process.resourcesPath is calculated from the "assets" path
// However, it is read only once, before the shim actually runs, making it non-overridable.
// This means that process.resourcesPath has to be patched manually
console.log("process.resourcesPath == ", process.resourcesPath);

// Load the actual electron app
require(appPath);
