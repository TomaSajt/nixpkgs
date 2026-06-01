// Electron loading logic:
// - Step 1: main electron entrypoint (https://github.com/electron/electron/blob/main/lib/browser/init.ts)
// - Step 2: resources/default_app.asar (https://github.com/electron/electron/blob/main/default_app/main.ts)
// - Step 3: electron-shim.js
// - Step 4: app.asar

import { app } from "electron";
import assert from "node:assert";
import * as path from "node:path";
import * as url from "node:url";
import { Module } from "node:module";

function getEnvOrThrow(v) {
  const res = process.env[v];
  if (!res) throw new Error(`${v} is not set.`);
  return res;
}

const appPath = path.resolve(getEnvOrThrow("ELECTRON_SHIM_APP_PATH"));
const wrapperPath = path.resolve(getEnvOrThrow("ELECTRON_SHIM_WRAPPER_PATH"));
const resourcesPath = path.dirname(appPath);

if (!process.argv[1].endsWith("electron-shim.js")) {
  throw new Error("argv[1] was not electron-shim.js");
}

// Now we modify process.argv:
// original: ["path/to/electron", "path/to/electron-shim.js", "first-arg", "second-arg", ...]
// modified: ["path/to/wrapper", "first-arg", "second-arg", ...]
process.argv[0] = wrapperPath;
process.argv.splice(1, 1); // delete index 1 element

process.execPath = wrapperPath;
app.setPath("exe", wrapperPath); // This also makes app.isPackaged give true as a result
assert(app.isPackaged);

process.title = wrapperPath;

function forceWriteProcessProp(prop, val) {
  Object.defineProperty(process, prop, {
    value: val,
    configurable: true,
    enumerable: true,
    writable: false,
  });
}

// just setting process.resourcesPath doesn't work, as it is handled by C++
forceWriteProcessProp("resourcesPath", resourcesPath);
forceWriteProcessProp("helperExecPath", wrapperPath); // does this break anything?
// forceWriteProcessProp("argv0", wrapperPath); // not allowed :(
// forceWriteProcessProp("defaultApp", false); // not allowed :(

// we should probably keep it as-is because then we don't have to copy/symlink all the assets into the app output
// app.setPath("assets", assetsPath);

// This next section is taken from https://github.com/electron/electron/blob/main/default_app/main.ts
const packageJsonPath = path.join(appPath, "package.json");
const emitWarning = process.emitWarning;
process.emitWarning = () => {};
let packageJson = (
  await import(url.pathToFileURL(packageJsonPath).toString(), {
    with: { type: "json" },
  })
).default;
process.emitWarning = emitWarning;

if (packageJson.version) {
  app.setVersion(packageJson.version);
}
if (packageJson.productName) {
  app.name = packageJson.productName;
} else if (packageJson.name) {
  app.name = packageJson.name;
}

// See lib/browser/desktop-name.ts
function defaultDesktopName(name) {
  const slug =
    name &&
    name
      .normalize("NFKD")
      .replace(/\p{M}/gu, "")
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "");
  return slug
    ? `${slug}.desktop`
    : `${path.basename(process.execPath)}.desktop`;
}

app.setDesktopName(packageJson.desktopName || defaultDesktopName(app.name));

// Set v8 flags, deliberately lazy load so that apps that do not use this
// feature do not pay the price
if (packageJson.v8Flags) {
  (await import("node:v8")).setFlagsFromString(packageJson.v8Flags);
}

app.setAppPath(appPath);

// Run the app.
const filePath = Module._resolveFilename(appPath, null, true);
await import(url.pathToFileURL(filePath).toString());
