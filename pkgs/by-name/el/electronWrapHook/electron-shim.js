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
const wrapperPath = getEnvOrExit("ELECTRON_SHIM_WRAPPER_PATH");

// ["path/to/electron", "path/to/electron-shim.js", "first-arg", "second-arg", ...]
console.log("process.argv : ", JSON.stringify(process.argv));

process.argv[0] = wrapperPath;

if (!process.argv[1].endsWith("electron-shim.js")) {
  console.error("argv[1] was not electron-shim.js, exiting...");
  app.exit();
}
process.argv.splice(1, 1);

// ["path/to/wrapper", "first-arg", "second-arg", ...]
console.log("process.argv : ", JSON.stringify(process.argv));

app.setPath("exe", wrapperPath); // This also makes app.isPackaged give true as a result

console.log('app.getPath("exe") : ', app.getPath("exe"));
console.log("app.isPackaged : ", app.isPackaged);

// we should probably keep it as-is because then we don't have to copy/symlink all the assets into the app output
// app.setPath("assets", assetsPath);

console.log('app.getPath("assets") : ', app.getPath("assets"));

// The value of process.resourcesPath is calculated via `app.getPath("assets") + "/resources"`
// However, it is read only once, before the shim actually runs, making it non-overridable.
// This means that process.resourcesPath has to be patched manually in each file using it
console.log("process.resourcesPath : ", process.resourcesPath);

// Load the actual electron app
require(appPath);
