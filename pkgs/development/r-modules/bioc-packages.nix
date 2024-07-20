let
  # This is in the outer scope to ensure that it gets put into the import-value cache of Nix
  packagesJSON = builtins.fromJSON (builtins.readFile ./bioc-packages.json);
  biocInfo = builtins.fromJSON (builtins.readFile ./bioc-info.json);
in
{ self, derive }:
let
  derive2 = derive { biocVersion = biocInfo.version; };
in
builtins.mapAttrs (
  k: v: derive2 (v // { depends = builtins.map (name: self.${name}) v.depends; })
) packagesJSON
